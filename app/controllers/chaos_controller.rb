# frozen_string_literal: true

class ChaosController < ApplicationController
  include ActionController::MimeResponds

  respond_to :json
  respond_to :html

  attr_accessor :url

  def endexperiment
    session_guid = params[:session_guid]

    Rails.logger.info "Ending Experiment for #{session_guid}"

    chaos_sessions = Chaos::ChaosSession.where(session_guid: session_guid)

    unless chaos_sessions.any?
      redirect_to client_app_participant_path
      return
    end

    study_definition = StudyDefinition.find(chaos_sessions.first.study_definition_id)

    chaos_sessions.each { |session| session.experiment&.finalize }

    chaos_sessions.destroy_all
    Chaos::ChaosSession.clear_expired!

    unless study_definition
      redirect_to client_app_path
      return
    end

    redirect_to study_definition.redirect_close_on_url
  end
end
