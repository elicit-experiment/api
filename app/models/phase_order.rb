class PhaseOrder < ApplicationRecord
  has_one :user, foreign_key: "principal_investigator_user_id"
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  has_one :protocol, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
end
