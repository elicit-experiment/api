module Api::V1
  class TimeSeriesController < ApiController

    include StudyCreation

    include StudyResultConcern

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

      x = permit_json_params(params[:time_series], :time_series) do
        time_series_params = params.require(:time_series)
        pep = time_series_params.permit([:file,
                                         :study_definition_id,
                                         :protocol_definition_id,
                                         :phase_definition_id,
                                         :component_definition_id,
                                         :stage_id,
                                         :schema,
                                         :schema_matadata,
                                        ])
        pep
      end
    end
  end
end
