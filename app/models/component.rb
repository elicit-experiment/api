class Component < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
  belongs_to :trial_definition, :class_name => "TrialDefinition", :foreign_key => "trial_definition_id"

  has_many :data_point, :class_name => "StudyResult::DataPoint", :dependent => :destroy

 include Swagger::Blocks

  swagger_schema :ComponentDefinition do
    property :Inputs do
      key :type, :array
    end
    property :Outputs do
      key :type, :array
    end
  end
  swagger_schema :Component do
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
