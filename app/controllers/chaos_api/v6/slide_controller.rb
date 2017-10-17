module ChaosApi::V6
  class SlideController < ApplicationController

    include ActionController::MimeResponds

    before_action :cors_preflight_check
    after_action :cors_set_access_control_headers

    def get
      params.require([:sessionGUID, :questionaireId, :slideIndex])

      @protocol_id = params[:questionaireId]
      @slideIndex = params[:slideIndex]
      @sessionGUID = params[:sessionGUID]
      @response = ChaosResponse.new([])

      @chaos_session = Chaos::ChaosSession.where({:session_guid => @sessionGUID}).includes([:experiment, :phase_definition, :stage]).first

      @protocol_definition = ProtocolDefinition.find(@protocol_id)

      @chaos_session.stage.last_completed_trial = @slideIndex

      @chaos_session.stage.save!

      @response = ChaosResponse.new([])

      respond_to do |format|
        format.xml { render :xml => '' }
        format.json { render :json => @response.to_json }
      end
    end

    private
  end
end
