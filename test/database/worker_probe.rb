# frozen_string_literal: true

# Uses the real queue adapter/worker process, independently of Active Job's test adapter.
raise 'Worker probe requires the test environment' unless Rails.env.test?

require 'timeout'
ActiveRecord::Base.logger = nil
SolidQueue.connects_to = { database: { writing: :queue } }
TestJob.queue_adapter = :solid_queue
job = TestJob.perform_later
raise 'Worker probe was not enqueued' unless job&.successfully_enqueued?

# Run a separate Ruby process so the worker must observe the committed queue row.
worker = Process.spawn(RbConfig.ruby, Rails.root.join('bin/rails').to_s, 'runner',
                       'SolidQueue.connects_to = { database: { writing: :queue } }; worker = SolidQueue::Worker.new(queues: "*", threads: 1, polling_interval: 0.1); worker.mode = :inline; worker.start',
                       out: Rails.root.join('tmp/database-worker.log').to_s, err: [:child, :out], pgroup: true)
begin
  Timeout.timeout(30) do
    loop do
      saved = SolidQueue::Job.find_by!(active_job_id: job.job_id)
      break if saved.finished_at
      raise "Worker probe failed: #{saved.failed_execution.error}" if saved.failed_execution
      if Process.waitpid(worker, Process::WNOHANG)
        worker = nil
        raise 'Worker exited before executing the probe'
      end
      sleep 0.1
    end
  end
  Timeout.timeout(10) { Process.waitpid(worker) }
  worker = nil
  puts "Real worker executed #{job.job_id} using #{SolidQueue::Record.connection.adapter_name}"
ensure
  begin
    if worker
      Process.kill('TERM', worker)
      Timeout.timeout(5) { Process.waitpid(worker) }
    end
  rescue Errno::ESRCH, Errno::ECHILD
    # Already exited.
  rescue Timeout::Error
    Process.kill('KILL', worker)
    Process.waitpid(worker)
  end
end
