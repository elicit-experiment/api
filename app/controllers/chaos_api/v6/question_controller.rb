module ChaosApi::V6
  class QuestionController < ApplicationController
    #### uncomment to add authentication
    #  http_basic_authenticate_with name:"florian", password:"dtucompute", only: [:index]

    def show
      #  @experiment = Experiment.find(params[:id])
      #  respond_to do |format|
      #    format.html #show.html.erb
      #  #  format.xml {render xml: @experiment, :include => { :trials => { :except => :trial_id } } }
      #    format.xml {render xml: @experiment, :include =>  :trials}
      #    format.json {render :json =>@experiment, :include =>  :trials}
      #  end
      experiment_id = params[:id]
      trial_index = (params[:index] || "0").to_i

      ExperimentXmls.instance.refresh
      @experiment = ExperimentXmls.instance.experiment_by_id[experiment_id] || {}
      @experiment_n = ExperimentXmls.instance.experiment_n_by_id[experiment_id]
      @results = ExperimentXmls.get_questions(@experiment_n, trial_index)
      @response = ChaosResponse.new(@results)
      @response.Body["FoundCount"] = @experiment_n.css("Experiment>Trials").children.count
      @response.Body["StartIndex"] = trial_index

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
