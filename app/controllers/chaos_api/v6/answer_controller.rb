module ChaosApi::V6
  class AnswerController < ApplicationController

    include ActionController::MimeResponds

    before_action :cors_preflight_check
    after_action :cors_set_access_control_headers

    def create
      @response = ChaosResponse.new([])

      questionId = params[:questionId].split(':')
      study_definition_id = questionId[0].to_i
      component_definition_id = questionId[1].to_i

      @component = Component.find(component_definition_id)

      sessionGUID = params[:sessionGUID]

      @study_definition = StudyDefinition.find(study_definition_id)

      @chaos_session = Chaos::ChaosSession.where({:session_guid => sessionGUID}).first

      output = JSON.parse(params[:output])

      new_datapoints = output["Events"].map do |event|
        StudyResult::DataPoint.new({
          :study_definition_id => study_definition_id,
          :protocol_definition_id => @component.protocol_definition_id,
          :phase_definition_id => @component.phase_definition_id,
          :trial_definition_id => @component.trial_definition_id,
          :component_id => @component.id,
          :user_id => @chaos_session.user_id,
          :point_type => event["Type"],
          :kind => event["EventId"],
          :value => event["Data"],
          :method => event["Method"],
          :datetime => event["DateTime"]
          }).save!
      end

      output.delete("Events")

      state = StudyResult::DataPoint.find_or_create_by({
          :study_definition_id => study_definition_id,
          :protocol_definition_id => @component.protocol_definition_id,
          :phase_definition_id => @component.phase_definition_id,
          :trial_definition_id => @component.trial_definition_id,
          :component_id => @component.id,
          :user_id => @chaos_session.user_id,
          :point_type => "State"
        })

      state.value = output.to_json
      state.datetime = DateTime.now
      state.save!

      if output["Context"]
        context = StudyResult::Context.find_or_create_by({
          :context_type => output["Context"]["Type"],
          :data => output["Context"]["Data"],
          })
        context.save!
        ap context
      end

      ap new_datapoints

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
