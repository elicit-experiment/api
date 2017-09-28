module Api::V1
  class TrialDefinitionsController < ApiController

    include StudyCreation

    private

    def trial_definition_params
      ap params.permit!
      permit_json_params(params[:trial_definition], :trial_definition) do
        params.require(:trial_definition).permit(:definition_data)
      end
    end
  end
end
