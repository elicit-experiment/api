class ProtocolDefinition < ApplicationRecord
  belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"

  has_many :phase_definitions, :dependent => :destroy
  has_many :protocol_users, :dependent => :destroy
  has_many :phase_orders, :dependent => :destroy

  def principal_investigator_user_id
    study_definition.principal_investigator_user_id
  end

  include Swagger::Blocks

  swagger_schema :ProtocolDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :summary do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :definition_data do
      key :type, :string
    end
  end
end
