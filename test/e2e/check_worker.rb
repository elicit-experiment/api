# frozen_string_literal: true

raise 'Worker probe requires the owned test harness' unless Rails.env.test? && ENV['ELICIT_E2E'] == '1'

job = TestJob.perform_later
raise 'Worker probe was not enqueued' unless job&.successfully_enqueued?

deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 30
loop do
  saved = SolidQueue::Job.find_by(active_job_id: job.job_id)
  break if saved&.finished_at

  if saved && SolidQueue::FailedExecution.exists?(job_id: saved.id)
    raise "Worker probe failed: #{job.job_id}"
  end
  raise "Worker did not execute probe within 30 seconds: #{job.job_id}" if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline

  sleep 0.25
end
puts "Worker executed probe #{job.job_id}"
