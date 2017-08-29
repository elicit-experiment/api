class PhaseDefinition < ApplicationRecord
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  has_one :protocol, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
end
