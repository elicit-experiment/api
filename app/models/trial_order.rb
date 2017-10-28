class TrialOrder < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"

  def self.default_order(trials)
    (0..trials.count).to_a
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
