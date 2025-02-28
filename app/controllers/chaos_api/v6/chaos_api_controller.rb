# frozen_string_literal: true

module ChaosApi
  module V6
    class ChaosApiController < ApplicationController
      include ActionController::MimeResponds
      include ActionController::Cookies
      include ElicitErrors

      before_action :ensure_session

      def ensure_session
        session_guid = params[:sessionGUID] || cookies[:session_guid]

        @chaos_session = Chaos::ChaosSession.where(session_guid: session_guid).take if session_guid

        head :unauthorized unless @chaos_session
      end
    end
  end
end
