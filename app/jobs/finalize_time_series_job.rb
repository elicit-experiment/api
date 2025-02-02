class FinalizeTimeSeriesJob < ApplicationJob
  queue_as :default

  def perform(*experiment_ids)
    StudyResult::Experiment.where(id: experiment_ids).find_each do |experiment|
      logger.info "Finalizing experiment #{experiment.id}"
      experiment.finalize
    end
  end
end
