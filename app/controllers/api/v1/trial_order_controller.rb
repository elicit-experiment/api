# frozen_string_literal: true

module Api::V1
  class TrialOrderController < ApiController
    include StudyCreation

    private

    def trial_order_params
      params.require(%i[study_definition_id protocol_definition_id phase_definition_id])
      permit_json_params(params[:trial_order], :trial_order) do
        origin = { study_definition_id: params[:study_definition_id],
                   protocol_definition_id: params[:protocol_definition_id],
                   phase_definition_id: params[:phase_definition_id] }
        params.require(:trial_order).permit(%i[sequence_data user_id]).merge(origin)
      end
    end
  end
end
