class TrialDefinition < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"

  has_many :components, :dependent => :destroy
  has_many :stimuli, :dependent => :destroy

  has_many :data_point, :class_name => "StudyResult::DataPoint", :dependent => :destroy

  include Swagger::Blocks

  swagger_schema :TrialDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :definition_data do
      key :type, :string
    end
  end

end
