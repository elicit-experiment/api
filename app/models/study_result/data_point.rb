module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class DataPoint < ApplicationRecord
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :trial_definition, :class_name => "TrialDefinition", :foreign_key => "trial_definition_id"
    belongs_to :component, :class_name => "StudyResult::Component", :foreign_key => "component_id"
    belongs_to :context, :class_name => "StudyResult::Context", :foreign_key => "context_id"
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"

    include Swagger::Blocks

    swagger_schema :DataPoint do
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :user_id do
        key :type, :integer
        key :format, :int64
      end
      property :study_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :protocol_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :phase_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :trial_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :context_id do
        key :type, :integer
        key :format, :int64
      end
      property :component_id do
        key :type, :integer
        key :format, :int64
      end
      property :kind do
        key :type, :string
        key :format, :string
      end
      property :point_type do
        key :type, :string
        key :format, :string
      end
      property :value do
        key :type, :string
        key :format, :string
      end
      property :started_at do
        key :type, :string
        key :format, :datetime
      end
      property :completed_at do
        key :type, :string
        key :format, :datetime
      end
    end
  end
end
