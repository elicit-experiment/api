# frozen_string_literal: true

module ChaosApi
  module V6
    class QuestionController < ApplicationController
      include ActionController::MimeResponds

      def show
        trial_index = (params[:index] || '0').to_i

        session_guid = params[:sessionGUID]

        @chaos_session = Chaos::ChaosSession.where(session_guid: session_guid).first

        @study_definition = @chaos_session.study_definition
        @phase_definition = @chaos_session.phase_definition
        @protocol_definition = ProtocolDefinition.find(params[:id])

        if params[:id].to_i != @chaos_session.protocol_definition.id.to_i
          Rails.logger.error("ID parameter doesn't match protocol ID for session. #{params[:id]} != #{@chaos_session.protocol_definition.id}")
          # TODO: return a json error in this case
          head :unprocessable_entity
          return
        end

        # experiment_id = @study_definition.data
        @effective_user_id = @chaos_session.user_id

        @trial_definition = nil
        if @chaos_session.preview?
          @trial_definition = TrialDefinition.find @chaos_session.trial_definition_id
          logger.info "PREVIEW SESSION #{@trial_definition.ai}"
        else
          logger.info 'REAL SESSION'
          @chaos_session.stage.current_trial = trial_index
          @chaos_session.stage.save!
        end

        svc = ChaosExperimentService.new(@study_definition,
                                         @protocol_definition,
                                         @phase_definition,
                                         @effective_user_id)
        @response = svc.make_slide(trial_index, nil, @trial_definition)

        if !@chaos_session.preview? && (trial_definition = svc.trial_definition)
          if @chaos_session.phase_definition_id != trial_definition.phase_definition.id
            Rails.logger.warn "Inconsistent phase definition #{@chaos_session.phase_definition_id} #{trial_definition.phase_definition.id}"
          end
          parms = {
            experiment_id: @chaos_session.experiment.id,
            protocol_user_id: @chaos_session.protocol_user_id,
            phase_definition_id: trial_definition.phase_definition.id,
            trial_definition_id: trial_definition.id
          }
          logger.info parms.ai
          trial_result = StudyResult::TrialResult.where(parms).first_or_initialize do |tr|
            tr.started_at = DateTime.now unless tr.started_at
            tr.save!
          end
          Rails.logger.info "START OF TRIAL: TrialResult: #{trial_result.ai}"
          @chaos_session.trial_result_id = trial_result ? trial_result.id : nil
          @chaos_session.save!
        end

        respond_to do |format|
          format.xml { render xml: @response.to_xml }
          format.json { render json: @response.to_json }
        end
      end

      private

      def post_params
        # validate POST parameters
        params.require(:experiment).permit(:author_id, :name)
      end
    end
  end
end
