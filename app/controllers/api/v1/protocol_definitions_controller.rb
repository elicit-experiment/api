module Api::V1
  class ProtocolDefinitionsController < ApiController

    include StudyCreation

    def take
      session_guid = SecureRandom.uuid
      study_definition_id = params[:study_definition_id]
      protocol_definition_id = params[:protocol_definition_id]
      session_params = {
        :user_id => current_user.id,
        :session_guid => session_guid,
        :url => "#{Rails.configuration.elicit['participant_frontend']['scheme']}://#{Rails.configuration.elicit['participant_frontend']['host']}:#{Rails.configuration.elicit['participant_frontend']['port']}/?session_guid=#{session_guid}#Experiment/#{protocol_definition_id}",
        :expires_at => Date.today + 1.day
      }
      session = Chaos::ChaosSession.new(session_params)

      study_result = StudyResult::StudyResult.find_or_create_by({
        :user_id => current_user.id,
        :study_definition_id => study_definition_id})

      study_result.save!

      experiment = StudyResult::Experiment.find_or_create_by({
        :user_id => current_user.id,
        :study_definition_id => study_definition_id,
        :protocol_definition_id => protocol_definition_id})

      experiment.save!
 
      # TODO: figure out how to find the first stage 
      start_phase = PhaseDefinition.where({
        :study_definition_id => study_definition_id,
        :protocol_definition_id => protocol_definition_id}).first!

      stage = StudyResult::Stage.find_or_create_by({
        :user_id => current_user.id,
        :study_definition_id => study_definition_id,
        :protocol_definition_id => protocol_definition_id,
        :phase_definition_id => start_phase.id})

      stage.save!

      session.study_definition_id = study_definition_id
      session.protocol_definition_id = protocol_definition_id
      session.phase_definition_id = start_phase.id
      session.experiment_id = experiment.id
      session.stage_id = stage.id
 
      if session.save
        respond_with session
      else
        render json: ElicitError.new("Failed to create session", :unprocessable_entity), status: :unprocessable_entity
      end
    end

    private

    def protocol_definition_params
      params.require(:study_definition_id)
      permit_json_params(params[:protocol_definition], :protocol_definition) do
        params.require(:protocol_definition).permit(:definition_data).merge(:study_definition_id => params[:study_definition_id])
      end
    end
  end
end
