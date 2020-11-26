# frozen_string_literal: true

module Api::V1
  class ProtocolUsersController < ApiController
    include StudyCreation

    private

    def response_includes
      [:user]
    end

    def protocol_user_params
      params.require(%i[study_definition_id protocol_definition_id])
      permit_json_params(params[:protocol_user], :protocol_user) do
        params.require(:protocol_user).permit(%i[user_id group_name]).merge(
          protocol_definition_id: params[:protocol_definition_id]
        )
      end
    end
  end
end
