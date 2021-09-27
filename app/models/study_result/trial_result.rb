# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class TrialResult < ApplicationRecord
    belongs_to :experiment, class_name: 'StudyResult::Experiment'
    belongs_to :protocol_user, class_name: 'ProtocolUser'
    belongs_to :phase_definition, class_name: 'PhaseDefinition'
    belongs_to :trial_definition, class_name: 'TrialDefinition'
  end
end
