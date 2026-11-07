# frozen_string_literal: true

class CanonicalResultRow < ApplicationRecord
  belongs_to :canonical_study_revision
  belongs_to :study_transfer_operation

  def readonly?
    persisted?
  end
end
