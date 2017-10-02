class AnswerController < ApplicationController
  #### uncomment to add authentication
  #  http_basic_authenticate_with name:"florian", password:"dtucompute", only: [:index]
  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  def create
    @response = ChaosResponse.new([])

    questionId = params[:questionId]
    output = JSON.parse(params[:output])

    context = Context.new({:QuestionId => questionId}.merge(output["Context"])) if output["Context"]
    events = output["Events"].each do |event|
      event["EventId"] = event["Id"]
      event.delete "Id"
      event = Event.new({:QuestionId => questionId}.merge(event))
    end

    ap context
    ap events

    #@post = Post.new(params[:post]) 

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
