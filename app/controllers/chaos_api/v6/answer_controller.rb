# frozen_string_literal: true

module ChaosApi
  module V6
    class AnswerController < BaseChaosController
      include ActionController::MimeResponds

      before_action :cors_preflight_check
      after_action :cors_set_access_control_headers
      before_action :load_chaos_session_guid
      before_action :require_chaos_session

      def create
        study_definition_id, component_definition_id, trial_definition_id = params[:questionId].split(':').map(&:to_i)

        # we must have the study definition, but we can have either the component or trial definition (c.f. ChaosExperimentService#make_slide)

        @study_definition = StudyDefinition.find(study_definition_id)

        @trial_definition = TrialDefinition.find(trial_definition_id) if trial_definition_id.present? && !trial_definition_id.zero?

        @component = Component.find(component_definition_id) if component_definition_id.present? && !component_definition_id.zero?

        unless [@study_definition, @component || @trial_definition].all?(&:present?)
          logger.error "Invalid answer #{params[:questionId]} #{[study_definition_id, component_definition_id, trial_definition_id].ai}"
          head :unprocessable_entity
          return
        end

        @chaos_answer_output = JSON.parse(params[:output].to_s)

        @datapoint_query_fields = {
          stage_id: @chaos_session.stage&.id,
          protocol_user_id: @chaos_session.protocol_user_id,
          phase_definition_id: (@component || @trial_definition).phase_definition_id,
          trial_definition_id: @component&.trial_definition_id || @trial_definition.id,
          component_id: @component&.id || 0
        }

        state_datapoint, request_data_points = StudyResult::DataPoint.from_chaos_output(@datapoint_query_fields, @chaos_answer_output)

        logger.info message: 'datapoint changes', data_point_ids: request_data_points.to_h { |dp| [dp.id || 'new', dp.changed?] }


        if @chaos_session.preview
          render_preview(state_datapoint, request_data_points)
        else
          render_real(state_datapoint, request_data_points)
        end
      end

      private

      def render_real(state_datapoint, request_data_points)
        updated_data_points = request_data_points.select(&:changed?)

        @stage = StudyResult::Stage.find @datapoint_query_fields[:stage_id]
        @phase_definition = PhaseDefinition.find @datapoint_query_fields[:phase_definition_id]
        @protocol_user = ProtocolUser.find @datapoint_query_fields[:protocol_user_id]
        @trial_definition ||= TrialDefinition.find @datapoint_query_fields[:trial_definition_id]

        StudyResult::DataPoint.transaction do
          # because CHAOS' semantics are to republish everything, blow away existing data points.
          # We can't easily go incremental because of chaos' rate limiting, which means some updates
          # might not fire, and it's not easy to keep track of which ones made it to the server and which
          # ones didn't.
          # Note that because state entities are updated separately, we don't nuke those.
          StudyResult::DataPoint.where(@datapoint_query_fields)
                                .where.not(point_type: 'State')
                                .delete_all
          state_datapoint.save!
          request_data_points.each do |data_point|
            # avoid ActiveRecord checking to see if the ids are valid by providing the associations directly
            data_point.trial_definition = @trial_definition
            data_point.phase_definition = @phase_definition
            data_point.trial_definition = @trial_definition
            data_point.protocol_user = @protocol_user
            data_point.stage = @chaos_session.stage
          end
          request_data_points.each(&:save!)
          logger.info message: "added data points #{updated_data_points.size}", data_point_ids: updated_data_points.map(&:id)
          @response = ChaosResponse.new([state_datapoint.id].concat(updated_data_points.map(&:id)))
        end

        if @chaos_answer_output['Context']
          context = StudyResult::Context.find_or_create_by(
            context_type: @chaos_answer_output['Context']['Type'],
            data: @chaos_answer_output['Context']['Data']
          )
          context.save!
        end

        respond_to do |format|
          format.xml { render xml: '' }
          format.json { render json: @response.to_json }
        end
      end

      def render_preview(state_datapoint, request_data_points)
        updated_data_points = request_data_points.select(&:changed?)

        @response = ChaosResponse.new([state_datapoint.id].concat(updated_data_points.map(&:id)))

        respond_to do |format|
          format.xml { render xml: '' }
          format.json { render json: @response.to_json }
        end
      end

      def post_params
        # validate POST parameters
        params.require(:experiment).permit(:author_id, :name)
      end
    end
  end
end
