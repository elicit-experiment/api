# frozen_string_literal: true

module Api::V1
  class TrialDefinitionsController < ApiController
    include StudyCreation

    private

    def trial_definition_params
      params.require(%i[study_definition_id protocol_definition_id phase_definition_id])
      permit_json_params(params[:trial_definition], :trial_definition) do
        origin = { study_definition_id: params[:study_definition_id],
                   protocol_definition_id: params[:protocol_definition_id],
                   phase_definition_id: params[:phase_definition_id] }
        params.require(:trial_definition).permit(%i[definition_data name description]).merge(origin)
      end
    end
  end
end
