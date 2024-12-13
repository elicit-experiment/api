# frozen_string_literal: true

module ChaosApi
  module V6
    class SessionsController < BaseChaosController
      before_action :load_chaos_session_guid, only: %i[create]
      before_action :require_chaos_session, only: %i[create]

      # POST /sessions
      # POST /sessions.json
      def create
        response.set_cookie(
          :session_guid,
          value: @session_guid,
          # expires: 60.minutes.from_now,
          path: '/',
          secure: Rails.configuration.elicit[:participant_frontend][:scheme] == 'https',
          httponly: true
        )

        @response = ChaosResponse.new([
                                        {
                                          "DateCreated": Time.now.to_i,
                                          "DateModified": Time.now.to_i,
                                          "FullName": 'Chaos.Portal.Core.Data.Model.Session',
                                          "Guid": @session_guid,
                                          "UserGuid": format('c0b231e9-7d98-4f52-885e-af48%08x', @chaos_session.user_id)
                                        }
                                      ])
        render json: @response.to_json, status: :ok
      end
    end
  end
end
