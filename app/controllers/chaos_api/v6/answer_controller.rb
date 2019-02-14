module ChaosApi::V6
  class AnswerController < ApplicationController

    include ActionController::MimeResponds

    before_action :cors_preflight_check
    after_action :cors_set_access_control_headers

    def create
      @response = ChaosResponse.new([])

      session_guid = params[:sessionGUID]

      @chaos_session = Chaos::ChaosSession.where({:session_guid => session_guid}).first

      question_id = params[:questionId].split(':')
      study_definition_id = question_id[0].to_i
      component_definition_id = question_id[1].to_i

      @component = Component.find(component_definition_id)

      @study_definition = StudyDefinition.find(study_definition_id)

      if @component.nil? || @study_definition.nil?
        logger.error "Invalid answer #{params[:questionId]}"
        head :unprocessable_entity
        return
      end

      output = JSON.parse(params[:output])

      datapoint_query_fields = {
          :stage_id => @chaos_session.stage&.id,
          :protocol_user_id => @chaos_session.protocol_user_id,
          :phase_definition_id => @component.phase_definition_id,
          :trial_definition_id => @component.trial_definition_id,
          :component_id => @component.id,
      }

      new_datapoints = StudyResult::DataPoint.from_chaos_output(datapoint_query_fields, output)

      if @chaos_session.preview
        logger.info params.permit!.ai
        logger.info new_datapoints.ai

        respond_to do |format|
          format.xml {render :xml => ''}
          format.json {render :json => @response.to_json}
        end

        return
      end

      StudyResult::DataPoint.transaction do
        # because CHAOS' semantics are to republish everything, blow away existing data points.
        # We can't easily go incremental because of chaos' rate limiting, which means some updates
        # might not fire, and it's not easy to keep track of which ones made it to the server and which
        # ones didn't.
        # Note that because state entities are updated separately, we don't nuke those.
        StudyResult::DataPoint.where(datapoint_query_fields)
            .where.not({:point_type => 'State'})
            .delete_all
        new_datapoints.each(&:save!)
      end

      if output["Context"]
        context = StudyResult::Context.find_or_create_by({
                                                             :context_type => output["Context"]["Type"],
                                                             :data => output["Context"]["Data"],
                                                         })
        context.save!
      end

      respond_to do |format|
        format.xml {render :xml => ''}
        format.json {render :json => @response.to_json}
      end
    end

    private

    def post_params
      #validate POST parameters
      params.require(:experiment).permit(:author_id, :name)
    end
  end
end
