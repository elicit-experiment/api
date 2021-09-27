# frozen_string_literal: true

class Stimulus < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition'
  belongs_to :protocol_definition, class_name: 'ProtocolDefinition'
  belongs_to :phase_definition, class_name: 'PhaseDefinition'
  belongs_to :trial_definition, class_name: 'TrialDefinition'

  include Swagger::Blocks

  swagger_schema :Stimulus do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :definition_data do
      key :type, :string
    end
  end
end
