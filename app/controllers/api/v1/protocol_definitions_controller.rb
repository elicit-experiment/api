module Api::V1
  class ProtocolDefinitionsController < ApiController

    include StudyCreation

    def take
      session_guid = SecureRandom.uuid
      study_definition_id = params[:study_definition_id]
      protocol_definition_id = params[:protocol_definition_id]

      protocol_user = ProtocolUser.where({
        :user_id => current_user.id,
        :protocol_definition_id => protocol_definition_id}).includes(:protocol_definition).first!

      unless protocol_user.protocol_definition.active
        render json: ElicitError.new("Cannot take protocol that isn't active.", :bad_request), status: :bad_request
        return
      end

      session_params = {
        :user_id => current_user.id,
        :session_guid => session_guid,
        :url => "#{Rails.configuration.elicit['participant_frontend']['scheme']}://#{Rails.configuration.elicit['participant_frontend']['host']}:#{Rails.configuration.elicit['participant_frontend']['port']}/?session_guid=#{session_guid}#Experiment/#{protocol_definition_id}",
        :expires_at => Date.today + 1.day,
        :study_definition_id => study_definition_id,
        :protocol_definition_id => protocol_definition_id,
        :protocol_user_id => protocol_user.id,
      }
      session = Chaos::ChaosSession.new(session_params)

      session.populate

      Rails.logger.info "Taking session #{session.ai}"

      if session.save
        respond_with session
      else
        render json: ElicitError.new("Failed to create session", :unprocessable_entity), status: :unprocessable_entity
      end
    end

    private
    def query_includes
      [:phase_definitions]
    end

    def response_includes
      [:phase_definitions]
    end

    def protocol_definition_params
      params.require(:study_definition_id)
      permit_json_params(params[:protocol_definition], :protocol_definition) do
        params.require(:protocol_definition).permit([:definition_data, :type, :name, :summary, :description, :active]).merge(:study_definition_id => params[:study_definition_id])
      end
    end
  end
end
