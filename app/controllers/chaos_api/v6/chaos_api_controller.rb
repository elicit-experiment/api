module ChaosApi::V6
  class ChaosApiController < ApplicationController

    include ActionController::MimeResponds

    include ActionController::Cookies

    before_action :get_session

    def get_session
      sessionGUID = params[:sessionGUID] || cookies[:session_guid]

      @chaos_session = Chaos::ChaosSession.where({:session_guid => sessionGUID}).take

      unless @chaos_session
        head :unauthorized
      end
    end

  end
end
