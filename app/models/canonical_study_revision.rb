# frozen_string_literal: true

class CanonicalStudyRevision < ApplicationRecord
  belongs_to :study_definition
  has_many :canonical_result_rows, dependent: :restrict_with_exception

  def readonly?
    persisted?
  end
end
