# frozen_string_literal: true

require 'tmpdir'

module StudyTransfers
  class Processor
    def initialize(operation, token)
      @operation = operation
      @token = token
    end

    def call
      authorize_requester!
      Dir.mktmpdir('study-transfer') do |directory|
        @directory = Pathname(directory)
        case @operation.kind
        when 'import_definition' then import_definition
        when 'import_results' then import_results
        when 'export_results' then export_results
        end
      end
    end

    private

    def authorize_requester!
      user = @operation.requester.reload
      allowed = user.is_admin? || (user.is_investigator? &&
        (!@operation.study_definition || @operation.study_definition.principal_investigator_user_id == user.id))
      raise InvalidDocument, [{ path: '/', code: 'authorization', message: 'Requester no longer has access' }] unless allowed
    end

    def phase!(name)
      changed = StudyTransferOperation.where(id: @operation.id, status: 'running', claim_token: @token)
                                      .update_all(phase: name, lease_expires_at: 30.minutes.from_now, updated_at: Time.current)
      raise LostClaim unless changed == 1
    end

    def input_file
      raise InvalidDocument, [{ path: '/', code: 'empty_document', message: 'An input document is required' }] unless @operation.source.attached?

      path = @directory.join('input')
      File.open(path, 'wb') { |file| @operation.source.download { |chunk| file.write(chunk) } }
      path
    end

    def contract_file
      path = @directory.join('contract.json')
      File.write(path, JSON.generate(@operation.canonical_study_revision.compiled_contract))
      path
    end

    def finish
      @operation.with_lock do
        @operation.check_claim!(@token)
        authorize_requester!
        yield
        @operation.update!(status: 'succeeded', phase: 'complete', lease_expires_at: nil)
      end
    end

    def import_definition
      phase!('validating_definition')
      compiled_path = @directory.join('compiled.json')
      Compiler.run('compile', input_file, compiled_path)
      compiled = JSON.parse(File.read(compiled_path))
      finish do
        study = @operation.study_definition
        if study
          study.lock!
          latest = CanonicalStudyRevision.where(study_definition: study).order(:id).last
          raise Conflict, 'The base revision has changed' unless latest&.definition_digest == @operation.options['expected_revision_id']
        else
          definition = compiled.fetch('definition')
          study = StudyDefinition.create!(title: definition.fetch('title'), description: definition['description'],
                                          principal_investigator: @operation.requester, show_in_study_list: false)
        end
        revision = CanonicalStudyRevision.find_by(study_definition: study, definition_digest: compiled.fetch('revision_id'))
        if revision && revision != CanonicalStudyRevision.where(study_definition: study).order(:id).last
          raise Conflict, 'Publishing a previously superseded revision requires a new definition'
        end

        revision ||= CanonicalStudyRevision.create!(study_definition: study, definition_digest: compiled.fetch('revision_id'),
                                                    contract_digest: compiled.fetch('result_contract_id'), compiled_contract: compiled)
        @operation.update!(study_definition: study, canonical_study_revision: revision,
                           result: { definition_digest: revision.definition_digest, result_contract_id: revision.contract_digest,
                                     runtime_status: 'definition_only' })
      end
    end

    def import_results
      phase!('validating_results')
      validated = @directory.join('validated.ndjson')
      Compiler.run('validate-results', contract_file, validated, '--rows', input_file)
      phase!('publishing_results')
      finish do
        count = 0
        File.foreach(validated).each_slice(500) do |lines|
          records = lines.map do |line|
            entry = JSON.parse(line)
            { canonical_study_revision_id: @operation.canonical_study_revision_id,
              study_transfer_operation_id: @operation.id, table_name: entry.fetch('table'),
              participant_id: entry.fetch('row').fetch('participant_id'), row_key: entry.fetch('row_key'), payload: entry.fetch('row') }
          end
          CanonicalResultRow.insert_all!(records)
          count += records.size
        end
        @operation.update!(result: { rows_imported: count })
      end
    end

    def export_results
      phase!('snapshotting')
      snapshot_id = SecureRandom.uuid
      rows_path = @directory.join('rows.ndjson')
      connection = ActiveRecord::Base.connection
      options = connection.adapter_name == 'PostgreSQL' && !connection.transaction_open? ? { isolation: :repeatable_read } : {}
      # Materialize a stable read snapshot before doing any conversion/upload.
      # Rows are append-only and each import publishes in one transaction.
      CanonicalResultRow.transaction(**options) do
        scope = CanonicalResultRow.where(canonical_study_revision_id: @operation.canonical_study_revision_id)
        requested = @operation.options['participant_ids']
        if requested
          found = scope.where(table_name: 'runs', participant_id: requested).distinct.pluck(:participant_id)
          unless (requested - found).empty?
            raise InvalidDocument,
                  [{ path: '/participant_ids', code: 'not_found', message: 'One or more participants have no imported runs' }]
          end

          scope = scope.where(participant_id: requested)
        end
        File.open(rows_path, 'w') do |file|
          scope.find_each(batch_size: 1000) { |row| file.puts(JSON.generate(table: row.table_name, row: row.payload)) }
        end
      end
      phase!('writing_parquet')
      archive = @directory.join('results.zip')
      Compiler.run('export', contract_file, archive, '--rows', rows_path, '--snapshot-id', snapshot_id)
      # Upload outside the primary transaction; publication is fenced by claim.
      phase!('uploading')
      blob = File.open(archive, 'rb') do |file|
        ActiveStorage::Blob.create_and_upload!(io: file, filename: "study-#{@operation.study_definition_id}-results.zip", content_type: 'application/zip',
                                               service_name: ENV.fetch('STUDY_TRANSFER_STORAGE_SERVICE', Rails.configuration.active_storage.service.to_s))
      end
      begin
        finish do
          @operation.artifacts.attach(blob)
          @operation.update!(result: { snapshot_id: snapshot_id, result_contract_id: @operation.canonical_study_revision.contract_digest,
                                       archive_sha256: Digest::SHA256.file(archive).hexdigest, link_expires_in_seconds: 300 })
        end
      rescue StandardError
        blob.purge if blob.attachments.none?
        raise
      end
    end
  end
end
