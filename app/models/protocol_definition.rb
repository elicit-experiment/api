class ProtocolDefinition < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"

  has_many :phase_definitions, :dependent => :delete_all
  has_many :phase_orders, :dependent => :delete_all

  include Swagger::Blocks

  swagger_schema :ProtocolDefinition do
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
