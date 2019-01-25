module Api::V1
  class PhaseDefinitionsController < ApiController

    include StudyCreation

    private

    def query_params
      {
        :study_definition_id => params[:study_definition_id],
        :protocol_definition_id => params[:protocol_definition_id]
      }
    end

    def query_includes
      [:trial_definitions]
    end

    def response_includes
      [:trial_definitions]
    end

    def phase_definition_params
      params.require([:study_definition_id, :protocol_definition_id])
      permit_json_params(params[:phase_definition], :phase_definition) do
        params.require(:phase_definition).permit([:definition_data, :trial_ordering]).merge({
          :study_definition_id => params[:study_definition_id],
          :protocol_definition_id => params[:protocol_definition_id]})
      end
    end
  end
end
