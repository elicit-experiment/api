module ChaosApi::V6
  class QuestionController < ApplicationController
    include ActionController::MimeResponds

    def show
      trial_index = (params[:index] || "0").to_i

      sessionGUID = params[:sessionGUID]

      @chaos_session = Chaos::ChaosSession.where({:session_guid => sessionGUID}).first

      @study_definition = @chaos_session.study_definition
      @phase_definition = @chaos_session.phase_definition
      @protocol_definition = ProtocolDefinition.find(params[:id])

      Rails.logger.info "LOG phase: #{@phase_definition.ai}"

      if params[:id].to_i != @chaos_session.protocol_definition.id.to_i
        Rails.logger.error("ID parameter doesn't match protocol ID for session. #{params[:id]} != #{@chaos_session.protocol_definition.id}")
        # TODO: return a json error in this case
        head :unprocessable_entity
        return
      end

      experiment_id = @study_definition.data

      unless @chaos_session.preview?
        logger.info "REAL SESSION"
        @chaos_session.stage.current_trial = trial_index
        @chaos_session.stage.save!
      end

      svc = ChaosExperimentService.new(@study_definition,
                                       @protocol_definition,
                                       @phase_definition,
                                       @chaos_session.user_id)
      @response = svc.make_slide(trial_index)

      unless @chaos_session.preview?
        trial_definition = svc.trial_definition
        if trial_definition
          if (@chaos_session.phase_definition_id != trial_definition.phase_definition.id)
            Rails.logger.warn "Inconsistent phase definition #{@chaos_session.phase_definition_id} #{trial_definition.phase_definition.id}"
          end
          parms = {
              :experiment_id => @chaos_session.experiment.id,
              :protocol_user_id => @chaos_session.protocol_user_id,
              :phase_definition_id => trial_definition.phase_definition.id,
              :trial_definition_id => trial_definition.id
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
            core_model = @response.Body[:Results][i]
#          Rails.logger.debug("DIFF:")
#          Rails.logger.debug(core_model.deep_diff(r).ai)
          end
        else
          Rails.logger.warn("Did not find experiment.xml for #{experiment_id}")
        end
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
