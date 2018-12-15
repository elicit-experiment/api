module Api::V1
  class DataPointsController < ApiController

    include StudyCreation

    include StudyResultConcern

    def index
      plural_resource_name = "@#{resource_name.pluralize}"

      pparams = params.permit([:study_id, :protocol_user_id, :phase_definition_id, :trial_definition_id, :component_id])
      where_components = pparams.to_h.keys.select{ |p| (p.to_s.end_with?('_id') && !params[p].nil?) }.map { |p| { p.to_sym => params[p] }  }

      where = where_components.reduce(&:merge)

      resources = StudyResult::DataPoint.where(where).includes(:protocol_user)

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                                  .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name), :include => [:protocol_user]
    end

    private

    def default_page_size
      100
    end

    def data_point_params
      params.require([:stage_id]).permit([:protocol_user_id, :phase_definition_id, :trial_definition_id, :component_id])
      permit_json_params(params[:data_point], :data_point) do
        origin = {:stage_id => params[:stage_id],
                  :protocol_user_id => params[:protocol_user_id],
                  :phase_definition_id => params[:phase_definition_id],
                  :trial_definition_id => params[:trial_definition_id],
                  :component_id => params[:component_id]
                 }
        params.require(:data_point).permit([
          :kind,
          :point_type,
          :value,
          :method,
          :datetime,
          ]).merge(origin)
      end
    end

    def query_params
      {
          :study_result_id => params[:study_result_id],
          :protocol_user_id => params[:protocol_user_id],
          :phase_definition_id => params[:phase_definition_id],
          :component_id => params[:component_id],
          :trial_definition_id => params[:trial_definition_id],
      }
    end
  end
end
