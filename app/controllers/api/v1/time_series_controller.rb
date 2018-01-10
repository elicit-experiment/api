module Api::V1
  class TimeSeriesController < ApiController

    include StudyCreation

    include StudyResultConcern

    include ActionController::MimeResponds

    respond_to :tsv, :csv

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

      parser_class_name = Rails.configuration.time_series_schema[time_series.schema]['plugin_class']

      parser_class = parser_class_name.classify.constantize

      parser = parser_class.new(time_series.schema_metadata)

      query_params = {
        :user_name => params[:user_name],
        :group_name => params[:group_name],
        :session_name => params[:session_name],
        :trial_definition_id => params[:trial_definition_id]
      }

      respond_to do |format|
        format.tsv do
          csv_filename='tobii_query.tsv'
          headers["X-Accel-Buffering"] = "no"
          headers["Cache-Control"] = "no-cache"
          headers["Content-Type"] = "text/tab-separated-values; charset=utf-8"
          self.content_type ||= Mime::TSV
          headers["Content-Disposition"] =
              %(attachment; filename="#{csv_filename}")
          headers["Last-Modified"] = Time.zone.now.ctime.to_s

          self.response_body = parser.query(time_series, query_params)
          return
        end
      end
    end

    def index
      plural_resource_name = "@#{resource_name.pluralize}"

      pparams = params.permit([:study_definition_id, :protocol_definition_id, :phase_definition_id, :trial_definition_id])
      where_components = pparams.to_h.keys.select{ |p| (p.to_s.end_with?('_id') && !params[p].nil?) }.map { |p| { p.to_sym => params[p] }  }

      where = where_components.reduce(&:merge)

      resources = StudyResult::TimeSeries.where(where)

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                        .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name), :include => [:user]
    end

    private

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
