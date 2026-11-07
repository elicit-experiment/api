# frozen_string_literal: true

class StudyTransferJob < ApplicationJob
  queue_as :study_transfers

  def perform(operation_id)
    operation = StudyTransferOperation.find(operation_id)
    token = operation.claim!
    return unless token

    StudyTransfers::Processor.new(operation.reload, token).call
  rescue StudyTransfers::LostClaim
    # A recovered attempt owns publication now.
  rescue StandardError => e
    raise unless operation && token

    issues = case e
             when StudyTransfers::InvalidDocument then e.issues
             when StudyTransfers::Conflict, ActiveRecord::RecordNotUnique
               [{ path: '/', code: 'conflict',
                  message: e.is_a?(StudyTransfers::Conflict) ? e.message : 'Results already contain one or more imported record identities' }]
             else
               Rails.logger.error("Study transfer #{operation.id} failed: #{e.class}: #{e.message}")
               [{ path: '/', code: 'processing_failed', message: 'Processing failed; retry the operation or inspect worker logs' }]
             end
    StudyTransferOperation.where(id: operation.id, status: 'running', claim_token: token)
                          .update_all(status: 'failed', phase: 'failed', diagnostics: issues, lease_expires_at: nil, updated_at: Time.current)
  end
end
