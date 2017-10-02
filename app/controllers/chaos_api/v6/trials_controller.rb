class TrialsController < ApplicationController

  def create
    @experiment = Experiment.find (params[:experiment_id])
    @trial = @experiment.trials.create(trial_params)
    redirect_to experiment_path(@experiment)
  end

  def destroy
    @experiment = Experiment.find(params[:experiment_id])
    @trial = @experiment.trials.find(params[:id])
    @trial.destroy
    redirect_to experiment_path(@experiment)
  end

  private def trial_params
  params.require(:trial).permit(:task_id)
  end
end
