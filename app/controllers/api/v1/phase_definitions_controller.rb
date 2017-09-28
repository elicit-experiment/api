module Api::V1
  class PhaseDefinitionsController < ApiController

    include StudyCreation

    private

    def phase_definition_params
      ap params.permit!
      permit_json_params(params[:phase_definition], :phase_definition) do
        params.require(:phase_definition).permit(:definition_data)
      end
    end
  end
end
