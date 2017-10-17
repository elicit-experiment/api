class StudyDefinition < ApplicationRecord
  belongs_to :principal_investigator, :class_name => "User", :foreign_key => "principal_investigator_user_id"

  has_many :protocol_definitions, :dependent => :delete_all



  include Swagger::Blocks

  swagger_schema :StudyDefinition do
    key :required, [:principal_investigator_user_id, :title]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :footer_label do
      key :type, :string
    end
    property :redirect_close_on_url do
      key :type, :string
    end
    property :data do
      key :type, :string
    end
    property :version do
      key :type, :integer
      key :format, :int32
    end
    property :enable_previous do
      key :type, :integer
      key :format, :int32
    end
    property :lock_question do
      key :type, :integer
      key :format, :int32
    end
    property :principal_investigator_user_id do
      key :type, :integer
      key :format, :int64
    end
  end
end
