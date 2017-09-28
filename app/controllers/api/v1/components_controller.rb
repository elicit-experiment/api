module Api::V1
  class ComponentsController < ApiController

    include StudyCreation

    private

    def component_params
      params.require(:study_definition_id, :protocol_definition_id, :phase_definition_id)
      permit_json_params(params[:component_params], :phase_definition) do
        origin = {:study_definition_id => params[:study_definition_id],
                  :protocol_definition_id => params[:protocol_definition_id],
                  :phase_definition_id => params[:phase_definition_id],
                  :trial_definition_id => params[:trial_definition_id]
                 }
        params.require(:component_params).permit(:definition_data).merge(origin)
      end
    end
  end
end
