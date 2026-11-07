# frozen_string_literal: true

require 'test_helper'
require 'open3'

class StudyDeliveryTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
    @investigator = user(:investigator)
    as_user(@investigator) { |headers| @headers = headers }
    @definition = File.read(Rails.root.join('study-format/examples/01-likert.study.json'))
  end

  def submit(path, body, key: SecureRandom.uuid, content_type: 'application/json')
    post path, params: body, headers: @headers.merge('Content-Type' => content_type, 'Idempotency-Key' => key)
    assert_response :accepted
    JSON.parse(response.body)
  end

  def complete(operation)
    StudyTransferJob.perform_now(operation.fetch('id'))
    get "/api/v2/study_operations/#{operation.fetch('id')}", headers: @headers
    assert_response :ok
    JSON.parse(response.body)
  end

  def create_revision
    operation = submit('/api/v2/study-imports', @definition)
    assert_equal 'queued', operation['status']
    result = complete(operation)
    assert_equal 'succeeded', result['status'], result['diagnostics'].inspect
    result
  end

  def revision_path(revision)
    "/api/v2/studies/#{revision['study_id']}/revisions/#{revision['revision_id']}"
  end

  def result_rows(revision, participant: 'participant-1', run: 'run-1')
    base = { revision_id: revision['revision_id'], participant_id: participant, run_id: run }
    occurrence = base.merge(protocol_key: 'main', phase_key: 'ratings', trial_key: 'baseline', trial_occurrence_id: "#{run}-trial-1")
    [
      { table: 'runs', row: base.merge(status: 'in_progress', started_at: '2026-11-07T12:00:00Z', completed_at: nil) },
      { table: 'trial_occurrences', row: occurrence.merge(status: 'completed', sequence: 0, started_at: '2026-11-07T12:00:00Z', completed_at: '2026-11-07T12:01:00Z') },
      { table: 'likert_v1_answer', row: occurrence.merge(component_path: 'main/ratings/baseline/rating', record_id: "#{run}-answer-1", sequence: 0, occurred_at: '2026-11-07T12:01:00Z', choice_key: 'option-1') }
    ]
  end

  def import_rows(revision, rows)
    operation = submit("#{revision_path(revision)}/result-imports", rows.map { |row| JSON.generate(row) }.join("\n"), content_type: 'application/x-ndjson')
    result = complete(operation)
    assert_equal 'succeeded', result['status'], result['diagnostics'].inspect
    result
  end

  def archive_summary(bytes)
    Tempfile.create(['delivery', '.zip']) do |file|
      file.binmode
      file.write(bytes)
      file.flush
      script = <<~PYTHON
        import hashlib, json, sys, zipfile
        import pyarrow as pa
        import pyarrow.parquet as pq
        with zipfile.ZipFile(sys.argv[1]) as archive:
            manifest = json.loads(archive.read('manifest.json'))
            participants = set()
            for entry in manifest['files']:
                payload = archive.read(entry['path'])
                assert hashlib.sha256(payload).hexdigest() == entry['sha256']
                if entry.get('table') == 'likert_v1_answer':
                    participants.update(pq.read_table(pa.BufferReader(payload))['participant_id'].to_pylist())
            print(json.dumps({'participants': sorted(participants), 'manifest': manifest}))
      PYTHON
      output, error, status = Open3.capture3(ENV.fetch('STUDY_FORMAT_PYTHON', 'python3'), '-c', script, file.path)
      assert status.success?, error
      JSON.parse(output)
    end
  end

  test 'whole definition and two participants round trip through jobs to a real Parquet download' do
    revision = create_revision
    get revision_path(revision), headers: @headers
    assert_response :ok
    assert_equal 'likert', JSON.parse(response.body)['key']
    get "#{revision_path(revision)}/result-schema", headers: @headers
    assert_response :ok
    assert JSON.parse(response.body)['tables'].key?('likert_v1_answer')

    import_rows(revision, result_rows(revision) + result_rows(revision, participant: 'participant-2', run: 'run-2'))
    export = complete(submit("#{revision_path(revision)}/result-exports", '{}'))
    assert_equal 'succeeded', export['status'], export['diagnostics'].inspect
    get URI(export['artifacts'].first['url']).request_uri, headers: @headers
    assert_response :ok
    assert_equal 'application/zip', response.media_type
    assert_equal export['result']['archive_sha256'], Digest::SHA256.hexdigest(response.body)
    summary = archive_summary(response.body)
    assert_equal %w[participant-1 participant-2], summary['participants']
    assert_equal revision['revision_id'], summary['manifest']['revision_id']
    assert_equal export['result']['snapshot_id'], summary['manifest']['snapshot_id']

    export = complete(submit("#{revision_path(revision)}/result-exports", JSON.generate(participant_ids: ['participant-2'])))
    get URI(export['artifacts'].first['url']).request_uri, headers: @headers
    assert_response :ok
    assert_equal ['participant-2'], archive_summary(response.body)['participants']
  end

  test 'S3 download URLs are short lived and refreshing them does not rerun exports' do
    revision = create_revision
    operation = complete(submit("#{revision_path(revision)}/result-exports", '{}'))
    attachment = StudyTransferOperation.find(operation['id']).artifacts_attachments.first
    # Exercise the non-Disk delivery branch without requiring cloud credentials.
    ActiveStorage::Blob.any_instance.stubs(:service).returns(Object.new)
    ActiveStorage::Blob.any_instance.expects(:url).with(expires_in: 5.minutes, disposition: 'attachment')
      .returns('https://storage.example/results.zip?signed=1').twice
    assert_no_enqueued_jobs only: StudyTransferJob do
      get "/api/v2/study_operations/#{operation['id']}", headers: @headers
      assert_response :ok
      artifact = JSON.parse(response.body)['artifacts'].first
      assert_equal 'https://storage.example/results.zip?signed=1', artifact['download_url']
      assert artifact['expires_at'].present?
      get "/api/v2/study_operations/#{operation['id']}/artifacts/#{attachment.id}", headers: @headers
      assert_response :redirect
      assert_equal 'https://storage.example/results.zip?signed=1', response.location
    end
  end

  test 'configured S3 signer uses the right bucket and avoids Spaces header overrides' do
    require 'active_storage/service/s3_service'
    storage = ActiveStorage::Service::S3Service.new(
      bucket: 'delivery-test', region: 'us-east-1', endpoint: 'https://storage.example',
      force_path_style: true, access_key_id: 'testing', secret_access_key: 'testing'
    )
    blob = ActiveStorage::Blob.new(key: 'archive-key')
    blob.stubs(:service).returns(storage)
    url = URI(StudyTransfers::ArtifactDelivery.signed_url(blob))
    query = URI.decode_www_form(url.query).to_h
    assert_equal 'storage.example', url.host
    assert_equal '/delivery-test/archive-key', url.path
    assert_equal '300', query['X-Amz-Expires']
    assert_not query.key?('response-content-disposition')
    assert_not query.key?('response-content-type')
  end

  test 'canonical definitions cannot be mutated through v1' do
    revision = create_revision
    as_user(user(:admin_user)) do |headers|
      patch "/api/v1/study_definitions/#{revision['study_id']}",
        params: { study_definition: { title: 'Bypassed definition' } }, headers: headers, as: :json
      assert_response :conflict
    end
    get revision_path(revision), headers: @headers
    assert_equal 'Sleepiness rating', JSON.parse(response.body)['title']
  end

  test 'all nine rewritten study documents can be delivered' do
    Rails.root.join('study-format/examples').glob('*.study.json').each do |path|
      operation = complete(submit('/api/v2/study-imports', File.read(path)))
      assert_equal 'succeeded', operation['status'], "#{path.basename}: #{operation['diagnostics']}"
      get revision_path(operation), headers: @headers
      assert_response :ok
      assert_equal JSON.parse(File.read(path))['key'], JSON.parse(response.body)['key']
    end
  end

  test 'a repeated submission returns its operation and a changed body conflicts' do
    first = submit('/api/v2/study-imports', @definition, key: 'same-request')
    assert_equal first['id'], submit('/api/v2/study-imports', @definition, key: 'same-request')['id']
    post '/api/v2/study-imports', params: '{}', headers: @headers.merge('Content-Type' => 'application/json', 'Idempotency-Key' => 'same-request')
    assert_response :conflict
    complete(first)
    assert_equal 1, CanonicalStudyRevision.count
  end

  test 'validation failure has diagnostics and publishes no revision or artifact' do
    operation = complete(submit('/api/v2/study-imports', '{}'))
    assert_equal 'failed', operation['status']
    assert operation['diagnostics'].present?
    assert_nil operation['study_id']
    assert_empty operation['artifacts']
    post "/api/v2/study_operations/#{operation['id']}/retry", headers: @headers
    assert_response :accepted
    assert_equal 'queued', JSON.parse(response.body)['status']
  end

  test 'result validation is atomic including cross-record references and duplicates' do
    revision = create_revision
    rows = result_rows(revision)
    rows.last[:row][:trial_occurrence_id] = 'missing'
    operation = complete(submit("#{revision_path(revision)}/result-imports", rows.map(&:to_json).join("\n"), content_type: 'application/x-ndjson'))
    assert_equal 'failed', operation['status']
    assert_equal 'result_reference', operation['diagnostics'].first['code']
    assert_equal 0, CanonicalResultRow.count
    import_rows(revision, result_rows(revision))
    duplicate = complete(submit("#{revision_path(revision)}/result-imports", result_rows(revision).map(&:to_json).join("\n"), content_type: 'application/x-ndjson'))
    assert_equal 'failed', duplicate['status']
    assert_equal 'conflict', duplicate['diagnostics'].first['code']
    assert_equal 3, CanonicalResultRow.count
  end

  test 'optimistic revision checks fail stale writers and preserve the old document' do
    revision = create_revision
    changed = JSON.parse(@definition).merge('title' => 'New title').to_json
    update = complete(submit("/api/v2/studies/#{revision['study_id']}/revision-imports?expected_revision_id=#{revision['revision_id']}", changed))
    assert_equal 'succeeded', update['status'], update['diagnostics'].inspect
    stale = complete(submit("/api/v2/studies/#{revision['study_id']}/revision-imports?expected_revision_id=#{revision['revision_id']}", @definition))
    assert_equal 'failed', stale['status']
    assert_equal 'conflict', stale['diagnostics'].first['code']
    get revision_path(revision), headers: @headers
    assert_equal 'Sleepiness rating', JSON.parse(response.body)['title']
  end

  test 'authorization applies to submissions, operation polling, definitions and artifacts' do
    revision = create_revision
    export = complete(submit("#{revision_path(revision)}/result-exports", '{}'))
    as_user(user(:investigator2)) do |headers|
      get "/api/v2/study_operations/#{export['id']}", headers: headers
      assert_response :forbidden
      get revision_path(revision), headers: headers
      assert_response :forbidden
      get URI(export['artifacts'].first['url']).request_uri, headers: headers
      assert_response :forbidden
    end
    get "/api/v2/study_operations/#{export['id']}"
    assert_response :unauthorized
    as_user(user(:subject1)) do |headers|
      post '/api/v2/study-imports', params: @definition, headers: headers.merge('Content-Type' => 'application/json', 'Idempotency-Key' => 'subject')
      assert_response :forbidden
    end
  end

  test 'expired worker claims can be recovered and duplicate jobs are harmless' do
    operation = submit('/api/v2/study-imports', @definition)
    record = StudyTransferOperation.find(operation['id'])
    old_token = record.claim!
    assert_nil record.claim!
    record.update!(lease_expires_at: 1.minute.ago)
    assert_enqueued_with(job: StudyTransferJob, args: [record.id]) { StudyTransferRecoveryJob.perform_now }
    result = complete(operation)
    assert_equal 'succeeded', result['status'], result['diagnostics'].inspect
    assert_raises(StudyTransfers::LostClaim) { record.check_claim!(old_token) }
    assert_no_difference 'CanonicalStudyRevision.count' do
      StudyTransferJob.perform_now(record.id)
    end
  end
end
