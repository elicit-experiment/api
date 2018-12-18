module Api::V1
  class ProtocolDefinitionsController < ApiController

    include StudyCreation

    #before_action :doorkeeper_authorize! # Requires access token for all actions

    def take
      @study_definition_id = params[:study_definition_id]
      @protocol_definition_id = params[:protocol_definition_id]
      set_protocol_user

      unless @protocol_user
        render json: ElicitError.new("Cannot find user for protocol.", :unauthorized), status: :unauthorized unless performed?
        return
      end

      unless @protocol_user.protocol_definition.active
        render json: ElicitError.new("Cannot take protocol that isn't active.", :bad_request), status: :bad_request
        return
      end

      session_guid = SecureRandom.uuid
      pfe = Rails.configuration.elicit['participant_frontend']
      session_params = {
          :user_id => @protocol_user.user_id,
          :session_guid => session_guid,
          :url => "#{pfe['scheme']}://#{pfe['host']}:#{pfe['port']}/?session_guid=#{session_guid}#Experiment/#{@protocol_definition_id}",
          :expires_at => Date.today + 1.day,
          :study_definition_id => @study_definition_id,
          :protocol_definition_id => @protocol_definition_id,
          :protocol_user_id => @protocol_user.id,
      }
      session = Chaos::ChaosSession.new(session_params)

      session.populate

      Rails.logger.info "Taking session #{session.ai}"

      if session.save
        respond_with session
      else
        logger.error session.errors.ai
        render json: ElicitError.new("Failed to create session", :unprocessable_entity), status: :unprocessable_entity
      end
    end

    def set_protocol_user
      if current_api_user_id
        @protocol_user = ProtocolUser
                             .where({:user_id => current_api_user_id,
                                     :protocol_definition_id => @protocol_definition_id})
                             .includes(:protocol_definition).first!
        return
      end

      Rails.logger.info "Not logged in during take; tring anonymous protocol."

      study_definition = StudyDefinition.find(@study_definition_id)

      return nil unless study_definition

      return nil unless study_definition.allow_anonymous_users

      candidate_protocol_users = ProtocolUser
                                     .where(protocol_definition_id: @protocol_definition_id)
                                     .left_outer_joins(:experiment)
                                     .where({:study_result_experiments => {protocol_user_id: nil}})

      Rails.logger.info "Anonymous protocol. Got #{candidate_protocol_users.size} candidates."

      @protocol_user = candidate_protocol_users.take
    end

    private

    def query_params
      {:study_definition_id => params[:study_definition_id]}
    end

    def query_includes
      {:phase_definitions => :trial_definitions}
    end

    def response_includes
      {:phase_definitions => {:include => :trial_definitions}}
    end

    def protocol_definition_params
      params.require(:study_definition_id)
      permit_json_params(params[:protocol_definition], :protocol_definition) do
        params.require(:protocol_definition).permit([:definition_data, :type, :name, :summary, :description, :active])
            .merge(:study_definition_id => params[:study_definition_id])
      end
    end
  end
end
