# frozen_string_literal: true

module Api::V1
  class ComponentsController < ApiController
    include StudyCreation

    private

    def component_params
      params.require(%i[study_definition_id protocol_definition_id phase_definition_id trial_definition_id])
      permit_json_params(params[:component], :component) do
        origin = { study_definition_id: params[:study_definition_id],
                   protocol_definition_id: params[:protocol_definition_id],
                   phase_definition_id: params[:phase_definition_id],
                   trial_definition_id: params[:trial_definition_id] }
        params.require(:component).permit(%i[definition_data name]).merge(origin)
      end
    end
  end
end
