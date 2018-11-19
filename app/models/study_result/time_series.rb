module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class TimeSeries < ApplicationRecord
    belongs_to :stage, :class_name => "Stage", :foreign_key => "stage_id"
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :component, :class_name => "Component", :foreign_key => "component_id", optional: true

    mount_uploader :file, TimeSeriesUploader
  end
end
