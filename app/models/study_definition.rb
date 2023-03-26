# frozen_string_literal: true

class StudyDefinition < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_study_definitions,
                  against: { title: 'A', description: 'B' },
                  using: {
                    tsearch: {
                      dictionary: 'english', tsvector_column: 'searchable'
                    }
                  }

  belongs_to :principal_investigator, class_name: 'User', foreign_key: 'principal_investigator_user_id'

  has_many :study_result, class_name: 'StudyResult::StudyResult', dependent: :destroy

  has_many :protocol_definitions, dependent: :destroy

  include Swagger::Blocks

  swagger_schema :StudyDefinition do
    key :required, %i[principal_investigator_user_id title]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :footer_label do
      key :type, :string
    end
    property :redirect_close_on_url do
      key :type, :string
    end
    property :data do
      key :type, :string
    end
    property :version do
      key :type, :integer
      key :format, :int32
    end
    property :enable_previous do
      key :type, :integer
      key :format, :int32
    end
    property :lock_question do
      key :type, :integer
      key :format, :int32
    end
    property :allow_anonymous_users do
      key :type, :boolean
    end
    property :show_in_study_list do
      key :type, :boolean
    end
    property :max_anonymous_users do
      key :type, :integer
      key :format, :int32
    end
    property :auto_created_user_count do
      key :type, :integer
      key :format, :int32
    end
    property :max_auto_created_users do
      key :type, :integer
      key :format, :int32
    end
    property :max_concurrent_users do
      key :type, :integer
      key :format, :int32
    end
    property :principal_investigator_user_id do
      key :type, :integer
      key :format, :int64
    end
  end
end
