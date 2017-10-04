class TrialDefinition < ApplicationRecord
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  has_one :protocol, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  has_one :phase, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"


  def self.default_order(trials)
    (0..trials.count).to_a
  end

  include Swagger::Blocks

  swagger_schema :TrialDefinition do
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
