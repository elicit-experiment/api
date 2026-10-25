# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class StudyResult < ApplicationRecord
    belongs_to :study_definition, class_name: 'StudyDefinition'
    belongs_to :user, class_name: 'User'

    has_many :experiments, class_name: 'StudyResult::Experiment', dependent: :destroy

    # All child results of this study result. Reads and mutations are scoped
    # through these associations so a child can never be reached via a
    # different study result's id.
    has_many :stages, class_name: 'StudyResult::Stage', through: :experiments
    has_many :trial_results, class_name: 'StudyResult::TrialResult', through: :experiments
    has_many :time_series, class_name: 'StudyResult::TimeSeries', through: :experiments
    has_many :data_points, class_name: 'StudyResult::DataPoint', through: :stages

    include Swagger::Blocks

    swagger_schema :StudyResult do
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :user_id do
        key :type, :integer
        key :format, :int64
      end
      property :study_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :started_at do
        key :type, :string
        key :format, :"date-time"
      end
      property :completed_at do
        key :type, :string
        key :format, :"date-time"
      end
    end
  end
end
