class PhaseDefinition < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"

  has_many :trial_definitions, :dependent => :destroy
  has_many :trial_orders, :dependent => :destroy
  has_many :trial_order_selection_mappings, :dependent => :destroy

  has_many :stage, :class_name => "StudyResult::Stage", :dependent => :destroy

  include Swagger::Blocks

  swagger_schema :PhaseDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :trial_ordering do
      key :type, :string
    end
    property :definition_data do
      key :type, :string
    end
  end
end
