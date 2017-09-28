class ProtocolDefinition < ApplicationRecord
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"

  include Swagger::Blocks

  swagger_schema :ProtocolDefinition do
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
