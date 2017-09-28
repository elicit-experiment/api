module Api::V1
  class StimuliController < ApiController

    include StudyCreation

    private

    def stimulus_params
      params.require(:study_definition_id, :protocol_definition_id, :phase_definition_id)
      permit_json_params(params[:stimulus_params], :phase_definition) do
        origin = {:study_definition_id => params[:study_definition_id],
                  :protocol_definition_id => params[:protocol_definition_id],
                  :phase_definition_id => params[:phase_definition_id],
                  :trial_definition_id => params[:trial_definition_id]
                 }
        params.require(:stimulus_params).permit(:definition_data).merge(origin)
      end
    end
  end
end
