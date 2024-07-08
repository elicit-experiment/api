# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class Stage < ApplicationRecord
    belongs_to :experiment, class_name: 'StudyResult::Experiment'
    belongs_to :protocol_user, class_name: 'ProtocolUser'
    belongs_to :phase_definition, class_name: 'PhaseDefinition'

    has_many :data_points, class_name: 'StudyResult::DataPoint', dependent: :delete_all
    has_many :time_series, class_name: 'StudyResult::TimeSeries', dependent: :destroy

    def trials_completed
      (last_completed_trial || -1) + 1
    end
  end
end
