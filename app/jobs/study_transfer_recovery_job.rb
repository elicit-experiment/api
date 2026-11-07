# frozen_string_literal: true

class StudyTransferRecoveryJob < ApplicationJob
  queue_as :study_transfers

  def perform
    StudyTransferOperation.where(status: 'queued').or(
      StudyTransferOperation.where(status: 'running').where('lease_expires_at < ?', Time.current)
    ).find_each { |operation| StudyTransferJob.perform_later(operation.id) }
  end
end
