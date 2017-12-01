module ChaosApi::V6
  class QuestionController < ApplicationController
    include ActionController::MimeResponds
    
    def show
      trial_index = (params[:index] || "0").to_i

      sessionGUID = params[:sessionGUID]

      @chaos_session = Chaos::ChaosSession.where({:session_guid => sessionGUID}).first

      @study_definition = @chaos_session.study_definition
      @protocol_definition = ProtocolDefinition.find(params[:id])

      if params[:id] != @chaos_session.protocol_definition.id
        Rails.logger.error("ID parameter doesn't match protocol ID for session. #{params[:id]} != #{@chaos_session.protocol_definition.id}")
        # TODO: return an error in this case
      end

      experiment_id = @study_definition.data

      unless @chaos_session.preview
        @chaos_session.stage.current_trial = trial_index
        @chaos_session.stage.save!
      end

      @response = ChaosExperimentService.new(@study_definition,
                                             @protocol_definition).make_slide(trial_index)

      # compare to version generated from experiment xml, if it exists
      ExperimentXmls.instance.refresh
      @experiment = ExperimentXmls.instance.experiment_by_id[experiment_id] || {}
      @experiment_n = ExperimentXmls.instance.experiment_n_by_id[experiment_id]
      if @experiment != nil and @experiment_n != nil then
        @results = ExperimentXmls.get_questions(@experiment_n, trial_index)
        @exml_response = ChaosResponse.new(@results)
        @exml_response.Body["FoundCount"] = @experiment_n.css("Experiment>Trials").children.count
        @exml_response.Body["StartIndex"] = trial_index

        @response = ChaosExperimentService.new(@study_definition).make_slide(trial_index, @chaos_session.protocol_user_id)

        Rails.logger.info("XML response #{@results.count} SD response #{@response.Body[:Results].count}")
        # compare the prototype generation with the new created one
        @results.each_with_index do |r, i| 
  #        ap i
          core_model = @response.Body[:Results][i]
          Rails.logger.info("DIFF:")
          ap core_model.deep_diff(r)
        end
      else
        Rails.logger.warn("Did not find experiment.xml for #{experiment_id}")
      end

      respond_to do |format|
        format.xml { render :xml => @response.to_xml }
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
