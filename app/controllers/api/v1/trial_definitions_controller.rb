module Api::V1
  class TrialDefinitionsController < ApiController

    include StudyCreation

    private

    def trial_definition_params
      params.require(:study_definition_id, :protocol_definition_id, :phase_definition_id)
      permit_json_params(params[:trial_definition_params], :phase_definition) do
        origin = {:study_definition_id => params[:study_definition_id],
                  :protocol_definition_id => params[:protocol_definition_id],
                  :phase_definition_id => params[:phase_definition_id],
                 }
        params.require(:trial_definition_params).permit(:definition_data).merge(origin)
      end
    end
  end
end
