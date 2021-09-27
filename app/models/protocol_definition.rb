# frozen_string_literal: true

class ProtocolDefinition < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition'

  has_many :phase_definitions, dependent: :destroy
  has_many :protocol_users, dependent: :destroy
  has_many :phase_orders, dependent: :destroy

  scope :with_anonymous_candidate_users, lambda {
    sql = <<~SQL
      SELECT *, (
          SELECT COUNT(*) from protocol_users
                            JOIN users ON protocol_users.user_id = users.id
                            LEFT OUTER JOIN study_result_experiments ON study_result_experiments.protocol_user_id = protocol_users.id
          WHERE protocol_users.protocol_definition_id = protocol_definitions.id AND
                (users.role = ? AND study_result_experiments.protocol_user_id IS NULL)
      ) AS protocol_users_count from protocol_definitions;
    SQL
    find_by_sql([sql, User::ROLES[:anonymous]])
  }

  delegate :principal_investigator_user_id, to: :study_definition

  def anonymous_candidate_users_count
    protocol_users.free_for_anonymous(id).size
  end

  def has_remaining_anonymous_slots
    anonymous_candidate_users_count.positive?
  end

  include Swagger::Blocks

  swagger_schema :ProtocolDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :summary do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :definition_data do
      key :type, :string
    end
  end
end
