# frozen_string_literal: true

class StudyTransferOperation < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :study_definition, optional: true
  belongs_to :canonical_study_revision, optional: true
  has_one_attached :source
  has_many_attached :artifacts

  validates :kind, inclusion: { in: %w[import_definition import_results export_results] }
  validates :status, inclusion: { in: %w[queued running succeeded failed] }

  def claim!
    token = SecureRandom.uuid
    changed = self.class.where(id: id).where(
      'status = ? OR (status = ? AND lease_expires_at < ?)', 'queued', 'running', Time.current
    ).update_all(status: 'running', phase: 'processing', claim_token: token,
                 lease_expires_at: 30.minutes.from_now, updated_at: Time.current)
    changed == 1 ? token : nil
  end

  def check_claim!(token)
    reload
    raise StudyTransfers::LostClaim unless status == 'running' && claim_token == token
  end
end
