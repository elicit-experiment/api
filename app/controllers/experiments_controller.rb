class ExperimentsController < ApplicationController
#### uncomment to add authentication
#  http_basic_authenticate_with name:"florian", password:"dtucompute", only: [:index]

def index
    #show all experiments
    @experiments = Experiment.all
    respond_to do |format|
    format.html #show.html.erb
    format.json {render :json =>@experiments, :include =>  :trials}
    format.xml {render xml:@experiments, include: :trials}
end
  end

def new
  @experiment = Experiment.new
end

def show
#  @experiment = Experiment.find(params[:id])
#  respond_to do |format|
#    format.html #show.html.erb
#  #  format.xml {render xml: @experiment, :include => { :trials => { :except => :trial_id } } }
#    format.xml {render xml: @experiment, :include =>  :trials}
#    format.json {render :json =>@experiment, :include =>  :trials}
#  end
  experiment_id = params[:id]

  ExperimentXmls.instance.refresh
  @experiment = ExperimentXmls.instance.experiment_by_id[experiment_id] || {}
  @results =  [ExperimentXmls.get_experiment(experiment)]
  @response = ChaosResponse.new(@results)

  respond_to do |format|
    format.xml { render :xml => @response.to_xml }
    format.json { render :json => @response.to_json }
  end
end

def create
  #show to the screen what you just sent
  #render plain: params[:experiment].inspect

  #validate the post_params
  @experiment = Experiment.new(post_params)
  if(@experiment.save)
    respond_to do |format|
     format.json{render :json => @experiment, :status => :created, :location => @experiment }
     format.xml{render :xml => @experiment, :status => :created, :location => @experiment }
     format.html {redirect_to @experiment}
   end

  else render 'new'
  end


end

def edit
  @experiment = Experiment.find(params[:id])
end

def update
  @experiment = Experiment.find(params[:id])

  #check the post_params, shouldn't it be experiment_params?
  if(@experiment.update(post_params))
      redirect_to @experiment #and return?
  else render 'edit'
  end
end

def destroy
  @experiment = Experiment.find (params[:id])
  @experiment.destroy

  redirect_to experiments_path
end

private def post_params
  #validate POST parameters
  params.require(:experiment).permit(:author_id, :name)
end

end


#####How to do a GET/POST request from Rails
# require 'net/http'
#
# url = URI.parse('http://www.example.com/index.html')
# req = Net::HTTP::Get.new(url.to_s)
# res = Net::HTTP.start(url.host, url.port) {|http|
#   http.request(req)
# }
# puts res.body


###How to convert XML to ruby hash
#object_hash = Hash.from_xml(xml_string)
###How to convert JSON to ruby hash
#object_hash = JSON.parse(json_string)

#how to render an XML file to a user
#render :file=>"/path/to/file.xml", :content_type => 'application/xml'

#     Different browsers display XML differently. Some try to be smart, others don't. You can't rely on that. If you want to display XML "as is" you need to render escaped XML as text.
#     In your controller action you'll have to call this:
#render :text => @template.h(File.read("/path/to/file.xml"))
