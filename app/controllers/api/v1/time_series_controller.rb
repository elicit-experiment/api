module Api::V1
  class TimeSeriesController < ApiController

    include StudyCreation

    include StudyResultConcern

    include ActionController::MimeResponds

    respond_to :tsv, :csv

    SEARCH_FIELDS = %i[stage_id study_definition_id protocol_definition_id
                      phase_definition_id trial_definition_id]

    def query_params
      {}
    end

    def show
      time_series = get_resource
      # TODO: send the query parameters to the schema plugin for this timeseries
      respond_with time_series
    end

    def show_content
      set_resource

      time_series = get_resource

      query_params = {
          :user_name => params[:user_name],
          :group_name => params[:group_name],
          :session_name => params[:session_name],
          :trial_definition_id => params[:trial_definition_id]
      }

      if query_params.empty?
        parser_class_name = Rails.configuration.time_series_schema[time_series.schema]['plugin_class']

        parser_class = parser_class_name.classify.constantize

        parser = parser_class.new(time_series.schema_metadata)

        response_body = parser.query(time_series, query_params)
      else
        # TODO: consider send_file here
        # [Accelerated Rails Downloads with NGINX | mattbrictson.com](https://mattbrictson.com/accelerated-rails-downloads)
        # file_name = Rails.root.join(time_series.file.path)
        # send_file(file_name, :type => "text/tab-separated-values")

        response_body = FileIO.open(time_series.file.path, "r")
      end

      respond_to do |format|
        format.tsv do
          csv_filename='query.tsv'
          headers["X-Accel-Buffering"] = "no"
          headers["Cache-Control"] = "no-cache"
          headers["Content-Type"] = "text/tab-separated-values; charset=utf-8"
          self.content_type ||= Mime::TSV
          headers["Content-Disposition"] =
              %(attachment; filename="#{csv_filename}")
          headers["Last-Modified"] = Time.zone.now.ctime.to_s

          self.response_body = response_body
        end
      end
    end

    def index
      plural_resource_name = "@#{resource_name.pluralize}"

      where = search_params
      logger.info "Search for time series with #{where.ai}"

      resources = StudyResult::TimeSeries.where(where)

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                        .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    private

    def search_params
      permitted_params = params.permit(SEARCH_FIELDS)
      logger.info "perm param #{permitted_params.to_h.ai}"
      permitted_params.to_h.keys.reject do |p|
        params[p].blank?
      end.select do |p|
        p.to_s.ends_with?('_id')
      end.map do |p|
        {p.to_sym => params[p]}
      end.reduce(&:merge)
    end

    def time_series_params
      params.permit!
      permit_json_params(params[:time_series], :time_series) do
        time_series_params = params.require(:time_series)
        pep = time_series_params.permit([:file,
                                         :study_definition_id,
                                         :protocol_definition_id,
                                         :phase_definition_id,
                                         :component_definition_id,
                                         :stage_id,
                                         :schema,
                                         :schema_metadata,
                                        ])
        pep
      end
    end
  end
end
