module StudyResult
  class Experiment < ApplicationRecord
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"

    has_many :study_result_stages, :dependent => :delete_all

    include Swagger::Blocks

    swagger_schema :Experiment do
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
