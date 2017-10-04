module ChaosApi::V6
  class QuestionController < ApplicationController
    include ActionController::MimeResponds
    
    def show
      experiment_id = "a9f56a58-aaaa-eeee-1355-012345678901"#params[:id]
      trial_index = (params[:index] || "0").to_i

      ExperimentXmls.instance.refresh
      @experiment = ExperimentXmls.instance.experiment_by_id[experiment_id] || {}
      @experiment_n = ExperimentXmls.instance.experiment_n_by_id[experiment_id]
      @results = ExperimentXmls.get_questions(@experiment_n, trial_index)
      @response = ChaosResponse.new(@results)
      @response.Body["FoundCount"] = @experiment_n.css("Experiment>Trials").children.count
      @response.Body["StartIndex"] = trial_index


      @response = StudyDefinition.find(params[:id]).to_chaos_questions(trial_index)

      ap @response
      ap @response.Body[:Results]

      @results.each_with_index do |r, i| 
        ap i
        ap r
        ap @response.Body[:Results][i]
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
