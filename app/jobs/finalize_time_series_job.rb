class FinalizeTimeSeriesJob < ApplicationJob
  queue_as :default

  # FinalizeTimeSeriesJob.perform_later experiment_ids
  # experiment_ids = StudyResult::TimeSeries.has_no_finalized_file.where.not(file: nil).take(10).map {|ts| ts.stage.experiment.id}
  def perform(*experiment_ids)
    StudyResult::Experiment.where(id: experiment_ids).find_each do |experiment|
      logger.info "Finalizing experiment #{experiment.id}"
      experiment.finalize
    end
  end
end
