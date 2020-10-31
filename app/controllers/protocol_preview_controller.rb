# frozen_string_literal: true

class ProtocolPreviewController < ApplicationController
  include ActionController::MimeResponds

  respond_to :json
  respond_to :html

  attr_accessor :url

  def take
    session_guid = SecureRandom.uuid
    x = params.require(%i[study_definition_id protocol_definition_id phase_definition_id trial_definition_id])
    study_definition_id = params[:study_definition_id]
    protocol_definition_id = params[:protocol_definition_id]
    phase_definition_id = params[:phase_definition_id]
    trial_definition_id = params[:trial_definition_id]

    @url = "#{Rails.configuration.elicit['participant_frontend']['scheme']}://#{Rails.configuration.elicit['participant_frontend']['host']}:#{Rails.configuration.elicit['participant_frontend']['port']}/?session_guid=#{session_guid}#Experiment/#{protocol_definition_id}"

    session_params = {
      user_id: current_user.id,
      session_guid: session_guid,
      url: @url,
      expires_at: Date.today + 1.day,
      study_definition_id: study_definition_id,
      protocol_definition_id: protocol_definition_id,
      protocol_user_id: nil,
      phase_definition_id: phase_definition_id,
      trial_definition_id: trial_definition_id,
      preview: true
    }
    session = Chaos::ChaosSession.new(session_params)

    Rails.logger.info "Taking session #{session.ai} #{session.valid?}"

    if session.save
      respond_with do |format|
        format.html { redirect_to session_params[:url] }
        format.json { render json: session.to_json }
      end
    else
      Rails.logger.error "Failed to validate session on save: #{session.errors.full_messages}"
      render json: ElicitError.new('Failed to create session', :unprocessable_entity), status: :unprocessable_entity
    end
  end
  end
