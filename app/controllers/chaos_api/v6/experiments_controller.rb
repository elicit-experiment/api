module ChaosApi::V6
  class ExperimentsController < ApplicationController

    include ActionController::MimeResponds

    def index
      # show all experiments
      @experiments = StudyDefinition.all.map(&:to_chaos)
      Rails.logger.info "#{@experiments.ai}"
      respond_to do |format|
        format.json { render :json => @experiments }
        format.xml  { render xml: @experiments }
      end
    end

    def show
      id = params[:id]
      sessionGUID = params[:sessionGUID]

      @chaos_session = Chaos::ChaosSession.where({:session_guid => sessionGUID}).includes([:stage, :study_definition, :protocol_definition]).first

      @experiment = ChaosExperimentService.new(@chaos_session.study_definition, @chaos_session.protocol_definition).make_experiment(@chaos_session.stage)

      @results =  [@experiment]
      @response = ChaosResponse.new(@results)

      ap @chaos_session
      ap @results

      respond_to do |format|
        format.html { redirect_to "#{root_url.chomp('/')}:8080/#Experiment/#{id}" }
        format.xml  { render :xml => @response.to_xml }
        format.json { render :json => @response.to_json }
      end
    end

    private def post_params
    #validate POST parameters
    params.require(:experiment).permit(:author_id, :name)
  end

end
end
