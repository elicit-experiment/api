class PhaseOrder < ApplicationRecord
  has_one :user_definition, foreign_key: "principal_investigator_user_id"
  has_one :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  has_one :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"

  include Swagger::Blocks

  swagger_schema :PhaseOrder do
    property :id do
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
