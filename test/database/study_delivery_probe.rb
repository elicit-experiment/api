# frozen_string_literal: true

# Run with `RAILS_ENV=test bin/rails runner test/database/study_delivery_probe.rb`.
# Uses committed primary records and a separate Solid Queue worker process.
raise 'Delivery probe requires the test environment' unless Rails.env.test?

require 'timeout'
require 'stringio'
SolidQueue.connects_to = { database: { writing: :queue } }
StudyTransferJob.queue_adapter = :solid_queue
worker = nil
operations = []
user = User.create!(email: "delivery-#{SecureRandom.hex(8)}@example.invalid", password: 'delivery-test-password', role: User::ROLES[:investigator])
worker_code = 'SolidQueue.connects_to = { database: { writing: :queue } }; worker = SolidQueue::Worker.new(queues: "study_transfers", threads: 1, polling_interval: 0.1); worker.mode = :inline; worker.start'

def wait_for_delivery(operation, worker)
  Timeout.timeout(30) do
    until %w[succeeded failed].include?(operation.reload.status)
      raise 'Delivery worker exited early' if Process.waitpid(worker, Process::WNOHANG)
      sleep 0.1
    end
  end
  raise operation.diagnostics.inspect unless operation.status == 'succeeded'
end

begin
  definition = File.read(Rails.root.join('study-format/examples/01-likert.study.json'))
  imported = StudyTransfers::Submission.create!(requester: user, kind: 'import_definition', key: SecureRandom.uuid, source: StringIO.new(definition))
  operations << imported
  worker = Process.spawn(RbConfig.ruby, Rails.root.join('bin/rails').to_s, 'runner', worker_code,
    out: Rails.root.join('tmp/study-delivery-worker.log').to_s, err: [:child, :out], pgroup: true)
  wait_for_delivery(imported, worker)
  # The worker's inline mode exits after draining its queue. Start a second
  # process for export, proving the revision and artifact survive process exits.
  Timeout.timeout(10) { Process.waitpid(worker) }
  worker = nil
  revision = imported.canonical_study_revision
  now = Time.current.iso8601(6)
  base = { revision_id: revision.definition_digest, participant_id: 'probe-participant', run_id: 'probe-run' }
  occurrence = base.merge(protocol_key: 'main', phase_key: 'ratings', trial_key: 'baseline', trial_occurrence_id: 'probe-occurrence')
  rows = [
    { table: 'runs', row: base.merge(status: 'in_progress', started_at: now, completed_at: nil) },
    { table: 'trial_occurrences', row: occurrence.merge(status: 'completed', sequence: 0, started_at: now, completed_at: now) },
    { table: 'likert_v1_answer', row: occurrence.merge(component_path: 'main/ratings/baseline/rating', record_id: 'probe-answer', sequence: 0, occurred_at: now, choice_key: 'option-1') }
  ]
  results = StudyTransfers::Submission.create!(requester: user, kind: 'import_results', key: SecureRandom.uuid,
    source: StringIO.new(rows.map(&:to_json).join("\n")), study: imported.study_definition, revision: revision)
  operations << results
  worker = Process.spawn(RbConfig.ruby, Rails.root.join('bin/rails').to_s, 'runner', worker_code,
    out: Rails.root.join('tmp/study-delivery-worker.log').to_s, err: [:child, :out], pgroup: true)
  wait_for_delivery(results, worker)
  raise 'Result batch was not published' unless results.result['rows_imported'] == 3
  Timeout.timeout(10) { Process.waitpid(worker) }
  worker = nil
  exported = StudyTransfers::Submission.create!(requester: user, kind: 'export_results', key: SecureRandom.uuid,
    source: StringIO.new('{}'), study: imported.study_definition, revision: imported.canonical_study_revision)
  operations << exported
  worker = Process.spawn(RbConfig.ruby, Rails.root.join('bin/rails').to_s, 'runner', worker_code,
    out: Rails.root.join('tmp/study-delivery-worker.log').to_s, err: [:child, :out], pgroup: true)
  wait_for_delivery(exported, worker)
  raise 'No downloadable archive was published' unless exported.artifacts.one?
  raise 'Archive signature is invalid' unless exported.artifacts.first.download.start_with?('PK')
  Timeout.timeout(10) { Process.waitpid(worker) }
  worker = nil
  puts "Real #{ActiveRecord::Base.connection.adapter_name} workers imported a revision and delivered a Parquet ZIP"
ensure
  if worker
    Process.kill('TERM', worker) rescue Errno::ESRCH
    begin
      Timeout.timeout(5) { Process.waitpid(worker) }
    rescue Timeout::Error
      Process.kill('KILL', worker) rescue Errno::ESRCH
      Process.waitpid(worker) rescue Errno::ECHILD
    rescue Errno::ECHILD
    end
  end
  # This probe has dedicated test records; retain normal fixtures and other jobs.
  operations.each { |operation| operation.source.purge; operation.artifacts.purge }
  study_ids = operations.filter_map { |operation| operation.reload.study_definition_id }.uniq
  CanonicalResultRow.where(study_transfer_operation_id: operations.map(&:id)).delete_all
  StudyTransferOperation.where(id: operations.map(&:id)).delete_all
  CanonicalStudyRevision.where(study_definition_id: study_ids).delete_all
  StudyDefinition.where(id: study_ids).delete_all
  user.destroy!
end
