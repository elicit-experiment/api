# frozen_string_literal: true

class TrialDefinition < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition'
  belongs_to :protocol_definition, class_name: 'ProtocolDefinition'
  belongs_to :phase_definition, class_name: 'PhaseDefinition', inverse_of: :trial_definitions

  has_many :components, dependent: :destroy
  has_many :stimuli, dependent: :destroy

  has_many :data_point, class_name: 'StudyResult::DataPoint', dependent: :destroy

  include Swagger::Blocks

  swagger_schema :TrialDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
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
