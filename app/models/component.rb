class Component < ApplicationRecord
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
  has_one :protocol, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  has_one :phase, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
  has_one :trial, :class_name => "TrialDefinition", :foreign_key => "trial_definition_id"
end
