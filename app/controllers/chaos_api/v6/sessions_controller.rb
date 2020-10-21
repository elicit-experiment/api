module ChaosApi::V6
  class SessionsController < ApplicationController
    before_action :set_session, only: [:show, :edit, :update, :destroy]

    # GET /sessions
    # GET /sessions.json
    def index
      @sessions = Session.all
    end

    # GET /sessions/1
    # GET /sessions/1.json
    def show
    end

    # GET /sessions/new
    def new
      @session = Session.new
    end

    # GET /sessions/1/edit
    def edit
    end

    # POST /sessions
    # POST /sessions.json
    def create
      # TODO: make this the "get session guid pre-action"
      referrer = request.referer
      Rails.logger.debug "Referer: #{referrer}"
      Rails.logger.debug request.cookies.ai
      session_guids = {}
      unless referrer.blank?
        qp = Rack::Utils.parse_nested_query URI(referrer).query
        session_guids[:referrer] = qp['session_guid']
      end
      session_guids[:cookie] = request.cookies['session_guid']
      session_guids[:query_param] = params[:sessionGUID]
      session_guid = session_guids.values.reject(&:blank?).first

      Rails.logger.info("#{session_guids.ai} -> #{session_guid}")

      session = Chaos::ChaosSession.where({:session_guid => session_guid}).first

      if session.nil?
        @response = ChaosResponse.new(nil, "Unknown session")
        render json: @response.to_json, :status => :unprocessable_entity
      else
        response.set_cookie(
          :session_guid,
          {
            value: session_guid,
            # expires: 60.minutes.from_now,
            path: '/',
            secure: Rails.configuration.elicit['participant_frontend']['scheme'] == 'https',
            httponly: true
          }
        )

        @response = ChaosResponse.new([
                                       {
                                         "DateCreated": Time.now.to_i,
                                         "DateModified": Time.now.to_i,
                                         "FullName": "Chaos.Portal.Core.Data.Model.Session",
                                         "Guid": session_guid,
                                         "UserGuid": "c0b231e9-7d98-4f52-885e-af48%08x" % session.user_id
                                       }
        ])
        render json: @response.to_json, :status => :ok
      end

    end

    # PATCH/PUT /sessions/1
    # PATCH/PUT /sessions/1.json
    def update
      respond_to do |format|
        if @session.update(session_params)
          format.html { redirect_to @session, notice: 'Session was successfully updated.' }
          format.json { render :show, status: :ok, location: @session }
        else
          format.html { render :edit }
          format.json { render json: @session.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /sessions/1
    # DELETE /sessions/1.json
    def destroy
      @session.destroy
      respond_to do |format|
        format.html { redirect_to sessions_url, notice: 'Session was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_params
      params.fetch(:session, {})
    end
  end
end
