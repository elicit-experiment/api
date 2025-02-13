# frozen_string_literal: true

module ChaosApi
  module V6
    class AnswerController < BaseChaosController
      include ActionController::MimeResponds
      include ChaosApi::V6::TraceLogging
      
      log_trace :create

      if Rails.env.development?
        log_trace :create
      end

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

        state_datapoint, request_data_point_params = StudyResult::DataPoint.from_chaos_output(@datapoint_query_fields, @chaos_answer_output)


        if @chaos_session.preview
          render_preview(state_datapoint, request_data_point_params)
        else
          render_real(state_datapoint, request_data_point_params)
        end
      end

      private

      def render_real(state_datapoint, request_data_point_params)
        @stage = StudyResult::Stage.find @datapoint_query_fields[:stage_id]
        @phase_definition = PhaseDefinition.find @datapoint_query_fields[:phase_definition_id]
        @protocol_user = ProtocolUser.find @datapoint_query_fields[:protocol_user_id]
        @trial_definition ||= TrialDefinition.find @datapoint_query_fields[:trial_definition_id]

        location_params = {
          stage_id: @stage.id,
          protocol_user_id: @protocol_user.id,
          phase_definition_id: @phase_definition.id,
          trial_definition_id: @trial_definition.id,
        }

        import_data_points = request_data_point_params.map { |dp| dp.merge(location_params) }

        StudyResult::DataPoint.transaction do
          # CHAOS' semantics are to republish everything, so we can end up with duplicates. The state datapoint is
          # handled differently: it is updated every time.

          state_datapoint.save!

          import_result = StudyResult::DataPoint.import import_data_points, validate: false

          logger.info message: "added data points #{import_data_points.size}", failed_instances: import_result.failed_instances, num_inserts: import_result.num_inserts
          @response = ChaosResponse.new(import_result.as_json.tap { |r| r['ids'] << state_datapoint.id })
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
        @response = ChaosResponse.new([state_datapoint.id].concat(request_data_points.pluck(:id)))

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
