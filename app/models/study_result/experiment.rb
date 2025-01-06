# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class Experiment < ApplicationRecord
    belongs_to :protocol_user, class_name: 'ProtocolUser'
    belongs_to :current_stage, class_name: 'StudyResult::Stage', optional: true
    belongs_to :study_result, class_name: 'StudyResult::StudyResult'

    has_many :stages, class_name: 'StudyResult::Stage', dependent: :destroy
    has_many :time_series, class_name: 'StudyResult::TimeSeries', through: :stages, dependent: :nullify # dependent of stage, which handles destroy
    has_many :trial_results, class_name: 'StudyResult::TrialResult', dependent: :destroy

    def finalize(asynchronous: false, force: true)
      raise 'Not implemented' if asynchronous

      logger.info "Finalizing experiment #{id}; Time series: #{time_series.map(&:id).join(', ')}"
      time_series.each { |series| series.finalize(force: force) }
    end
  end
end
