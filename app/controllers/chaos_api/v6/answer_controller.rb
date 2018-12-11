module ChaosApi::V6
  class AnswerController < ApplicationController

    include ActionController::MimeResponds

    before_action :cors_preflight_check
    after_action :cors_set_access_control_headers

    def create
      @response = ChaosResponse.new([])

      sessionGUID = params[:sessionGUID]

      @chaos_session = Chaos::ChaosSession.where({:session_guid => sessionGUID}).first

      questionId = params[:questionId].split(':')
      study_definition_id = questionId[0].to_i
      component_definition_id = questionId[1].to_i

      @component = Component.find(component_definition_id)

      @study_definition = StudyDefinition.find(study_definition_id)

      if @component.nil? || @study_definition.nil?
        logger.error "Invalid answer #{params[:questionId]}"
        head :unprocessable_entity
        return
      end

      output = JSON.parse(params[:output])

      new_datapoints = output["Events"].map do |event|
        dp_params = {
            :stage_id => @chaos_session.stage&.id,
            :protocol_user_id => @chaos_session.protocol_user_id,
            :phase_definition_id => @component.phase_definition_id,
            :trial_definition_id => @component.trial_definition_id,
            :component_id => @component.id,
            :point_type => event["Type"],
            :kind => event["EventId"] || event['Id'],
            :value => event["Data"],
            :method => event["Method"],
            :datetime => event["DateTime"]
        }
        StudyResult::DataPoint.new(dp_params)
      end

      state_dp_params = {
          :stage_id => @chaos_session.stage&.id,
          :protocol_user_id => @chaos_session.protocol_user_id,
          :phase_definition_id => @component.phase_definition_id,
          :trial_definition_id => @component.trial_definition_id,
          :component_id => @component.id,
          :point_type => "State"
      }

      if @chaos_session.preview

        logger.info params.permit!.ai
        logger.info new_datapoints.ai
        logger.info state_dp_params.ai

        respond_to do |format|
          format.xml { render :xml => '' }
          format.json { render :json => @response.to_json }
        end

        return
      end

      StudyResult::DataPoint.transaction { new_datapoints.each(&:save!) }

      state = StudyResult::DataPoint.where(state_dp_params).first_or_initialize

      output.delete("Events")
      state.value = output.to_json
      state.datetime = DateTime.now
      state.save!

      if output["Context"]
        context = StudyResult::Context.find_or_create_by({
          :context_type => output["Context"]["Type"],
          :data => output["Context"]["Data"],
          })
        context.save!
      end

      respond_to do |format|
        format.xml { render :xml => '' }
        format.json { render :json => @response.to_json }
      end
    end

    private

    def post_params
      #validate POST parameters
      params.require(:experiment).permit(:author_id, :name)
    end
  end
end
