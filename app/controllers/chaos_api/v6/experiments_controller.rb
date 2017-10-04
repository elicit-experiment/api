module ChaosApi::V6
  class ExperimentsController < ApplicationController

    include ActionController::MimeResponds

    def index
      # show all experiments
      @experiments = StudyDefinition.all.map(&:to_chaos)
      Rails.logger.info "#{@experiments.ai}"
      respond_to do |format|
        format.json { render :json => @experiments }
        format.xml { render xml: @experiments }
      end
    end

    def show
      id = params[:id]

      @experiment = StudyDefinition.find(id).to_chaos_experiment

      @results =  [@experiment]
      @response = ChaosResponse.new(@results)

      respond_to do |format|
        format.html { redirect_to "#{root_url.chomp('/')}:8080/#Experiment/#{id}" }
        format.xml { render :xml => @response.to_xml }
        format.json { render :json => @response.to_json }
      end
    end

    private def post_params
    #validate POST parameters
    params.require(:experiment).permit(:author_id, :name)
  end

end
end
