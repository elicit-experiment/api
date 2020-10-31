# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class StudyResult < ApplicationRecord
    belongs_to :study_definition, class_name: 'StudyDefinition', foreign_key: 'study_definition_id'
    belongs_to :user, class_name: 'User', foreign_key: 'user_id'

    has_many :experiments, class_name: 'StudyResult::Experiment', dependent: :destroy

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
