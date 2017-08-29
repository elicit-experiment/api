class ProtocolDefinition < ApplicationRecord
  has_one :study, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
end
