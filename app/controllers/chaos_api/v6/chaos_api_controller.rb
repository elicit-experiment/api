# frozen_string_literal: true

module ChaosApi
  module V6
    class ChaosApiController < ApplicationController
      include ActionController::MimeResponds

      include ActionController::Cookies

      before_action :get_session

      def get_session
        session_guid = params[:sessionGUID] || cookies[:session_guid]

        @chaos_session = Chaos::ChaosSession.where(session_guid: session_guid).take

        head :unauthorized unless @chaos_session
      end
    end
  end
end
