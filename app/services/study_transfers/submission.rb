# frozen_string_literal: true

require 'digest'
require 'tempfile'

module StudyTransfers
  class Submission
    LIMIT = 512.megabytes

    def self.create!(requester:, kind:, key:, source:, study: nil, revision: nil, options: {})
      raise ArgumentError, 'Idempotency-Key must contain 1 to 200 characters' if key.blank? || key.length > 200

      Tempfile.create('study-submission') do |file|
        digest, bytes = stage(source, file)
        options = options.deep_stringify_keys
        fingerprint = Digest::SHA256.hexdigest(JSON.generate([kind, study&.id, revision&.id, options.sort, digest]))
        existing = StudyTransferOperation.find_by(requester_id: requester.id, idempotency_key: key)
        return replay(existing, fingerprint) if existing

        operation = StudyTransferOperation.new(
          requester: requester, kind: kind, study_definition: study, canonical_study_revision: revision,
          options: options, idempotency_key: key, request_digest: fingerprint
        )
        operation = persist(operation, file, bytes, fingerprint)
        enqueue(operation)
        operation
      end
    end

    def self.enqueue(operation)
      # Recovery discovers committed submissions if enqueue fails or the process
      # exits between the primary and queue database commits.
      StudyTransferJob.perform_later(operation.id)
    rescue StandardError => e
      Rails.logger.error("Study transfer #{operation.id} awaits queue recovery: #{e.class}")
    end

    def self.stage(source, file)
      file.binmode
      digest = Digest::SHA256.new
      bytes = 0
      while (chunk = source.read(1024 * 1024))
        bytes += chunk.bytesize
        raise ArgumentError, 'Upload exceeds the 512 MiB limit' if bytes > LIMIT

        digest.update(chunk)
        file.write(chunk)
      end
      file.rewind
      [digest.hexdigest, bytes]
    end

    def self.persist(operation, file, bytes, fingerprint)
      blob = if bytes.positive?
               ActiveStorage::Blob.create_and_upload!(
                 io: file, filename: 'input', content_type: 'application/octet-stream',
                 service_name: ENV.fetch('STUDY_TRANSFER_STORAGE_SERVICE', Rails.configuration.active_storage.service.to_s)
               )
             end
      operation.transaction do
        operation.save!
        operation.source.attach(blob) if blob
      end
      operation
    rescue ActiveRecord::RecordNotUnique
      purge_unattached(blob)
      replay(StudyTransferOperation.find_by!(requester_id: operation.requester_id, idempotency_key: operation.idempotency_key), fingerprint)
    rescue StandardError
      purge_unattached(blob)
      raise
    end

    def self.purge_unattached(blob)
      blob.purge if blob&.attachments&.none?
    end

    def self.replay(operation, fingerprint)
      raise Conflict, 'Idempotency-Key was already used for a different request' unless operation.request_digest == fingerprint

      operation
    end
    private_class_method :stage, :persist, :purge_unattached, :replay
  end
end
