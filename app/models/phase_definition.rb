class PhaseDefinition < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"

  has_many :trial_definitions, :dependent => :delete_all
  has_many :trial_orders, :dependent => :delete_all

  include Swagger::Blocks

  swagger_schema :PhaseDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :definition_data do
      key :type, :string
    end
  end
end
