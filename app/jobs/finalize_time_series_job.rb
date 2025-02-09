class FinalizeTimeSeriesJob < ApplicationJob
  queue_as :default

  class << self
    def enqueue_in_progress
      in_progress = StudyResult::TimeSeries.has_no_finalized_file.where.not(file: nil)

      experiment_ids = in_progress.take(100).map do |ts|
        ts.stage.experiment.id
      end

      in_progress_active_storage = StudyResult::TimeSeries.has_no_finalized_file.where(file: nil).has_in_progress_file

      experiment_ids << in_progress_active_storage.take(100).map do |ts|
        ts.stage.experiment.id
      end

      FinalizeTimeSeriesJob.perform_later experiment_ids
    end
  end

  # FinalizeTimeSeriesJob.perform_later experiment_ids
  # experiment_ids = StudyResult::TimeSeries.has_no_finalized_file.where.not(file: nil).take(10).map {|ts| ts.stage.experiment.id}
  def perform(*experiment_ids)
    StudyResult::Experiment.where(id: experiment_ids).find_each do |experiment|
      logger.info "Finalizing experiment #{experiment.id}"
      experiment.finalize
    end
  end
end
