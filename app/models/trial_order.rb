class TrialOrder < ApplicationRecord
  has_one :user, foreign_key: "principal_investigator_user_id"
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  has_one :protocol, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  has_one :phase, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"

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
    property :name do
      key :type, :string
    end
    property :sequence_data do
      key :type, :string
    end
  end
end
