class ExperimentsController < ApplicationController
  http_basic_authenticate_with name:"florian", password:"dtucompute", only: [:index]

def index
    #show all experiments
    @experiments = Experiment.all
  end

def new
  @experiment = Experiment.new
end

def show
  @experiment = Experiment.find(params[:id])

  # require "active_support/all"
  # require "active_support"
  respond_to do |format|
    format.html #show.html.erb
  #  format.xml {render xml: @experiment, :include => { :trials => { :except => :trial_id } } }
  #  format.xml {render :xml => @experiment.to_xml( :include => { :trials => { :except => :trial_id } })}
    format.xml {render xml: @experiment.trials}
    ##another possible solution?
  #  @experiment = @experiment.map{|a| a.attributes}

    #how to render an XML file to a user
    #render :file=>"/path/to/file.xml", :content_type => 'application/xml'

    #     Different browsers display XML differently. Some try to be smart, others don't. You can't rely on that. If you want to display XML "as is" you need to render escaped XML as text.
    #
    # In your controller action you'll have to call this:
    #
    # render :text => @template.h(File.read("/path/to/file.xml"))
    format.json {render :json =>@experiment, :include =>  :trials}
  end
end

def create
  #show to the screen what you just sent
  #render plain: params[:experiment].inspect

  #check the post_params, shouldn't it be experiment_params?
  @experiment = Experiment.new(post_params)
  if(@experiment.save)
      redirect_to @experiment #and return?
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
  params.require(:experiment).permit(:author_id, :name)
end


end
