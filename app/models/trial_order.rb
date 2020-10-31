# frozen_string_literal: true

class TrialOrder < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition', foreign_key: 'study_definition_id'
  belongs_to :protocol_definition, class_name: 'ProtocolDefinition', foreign_key: 'protocol_definition_id'
  belongs_to :phase_definition, class_name: 'PhaseDefinition', foreign_key: 'phase_definition_id'

  belongs_to :user, class_name: 'User', foreign_key: 'user_id', optional: true

  has_many :trial_order_selection_mappings, dependent: :destroy

  def self.default_sequence(trials)
    trials.map(&:id).sort
  end

  include Swagger::Blocks

  swagger_schema :TrialOrder do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
    property :sequence_data do
      key :type, :string
    end
  end
end
