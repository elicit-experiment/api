module Api::V1
  class PhaseDefinitionsController < ApiController

    include StudyCreation

    private

    def phase_definition_params
      params.require([:study_definition_id, :protocol_definition_id])
      permit_json_params(params[:phase_definition], :phase_definition) do
        params.require(:phase_definition).permit([:definition_data, :name]).merge({
          :study_definition_id => params[:study_definition_id],
          :protocol_definition_id => params[:protocol_definition_id]})
      end
    end
  end
end
