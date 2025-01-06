# frozen_string_literal: true

module ChaosApi
  module V6
    class SlideController < ApplicationController
      include ActionController::MimeResponds

      # TODO: Add fetching the SessionGUID to the chaosApiController base controller
      # TODO: Add quick error json response method to ChaosApiController

      # /v6/Slide/Completed
      def get
        params.require(%i[sessionGUID questionaireId slideIndex])

        @protocol_id = params[:questionaireId]
        @slideIndex = params[:slideIndex].to_i
        @sessionGUID = params[:sessionGUID]
        @response = ChaosResponse.new([])

        inc = %i[experiment protocol_user study_definition phase_definition experiment stage]
        @chaos_session = Chaos::ChaosSession.where({ session_guid: @sessionGUID }).includes(inc).first

        if @chaos_session.preview?
          respond_to do |format|
            format.xml { render xml: '' }
            format.json { render json: @response.to_json }
          end

          return
        end

        svc = ChaosExperimentService.new(@chaos_session.study_definition,
                                         @chaos_session.protocol_definition,
                                         @chaos_session.phase_definition,
                                         @chaos_session.user_id)
        @trial_definition = svc.trial_for_slide_index(@slideIndex.to_i)

        if @trial_definition
          parms = {
            experiment_id: @chaos_session.experiment_id,
            protocol_user_id: @chaos_session.protocol_user_id,
            phase_definition_id: @chaos_session.phase_definition_id,
            trial_definition_id: @trial_definition.id
          }

          trial_result = StudyResult::TrialResult.find_by(parms)

          if trial_result.nil?
            Rails.logger.warn "Cannot find trial result in slide #{@slideIndex}"
          else
            trial_result.completed_at = DateTime.now
            Rails.logger.info message: 'END OF TRIAL: TrialResult', trial_results: trial_result
            trial_result.save!
          end
        end

        @protocol_definition = ProtocolDefinition.find(@protocol_id)

        @chaos_session.stage.last_completed_trial = @slideIndex
        num_completed_trials = @slideIndex + 1

        if num_completed_trials == @chaos_session.stage.num_trials
          Rails.logger.info 'Stage completed'
          @chaos_session.stage.completed_at = DateTime.now
          @chaos_session.stage.save!
          @chaos_session.next_stage
        else
          logger.info "trial completed #{@chaos_session.stage.last_completed_trial} vs. num_trials #{@chaos_session.stage.num_trials}"
          @chaos_session.stage.save!
        end

        @response = ChaosResponse.new([])

        respond_to do |format|
          format.xml { render xml: '' }
          format.json { render json: @response.to_json }
        end
      end
    end
  end
end
