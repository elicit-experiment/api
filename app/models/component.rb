# frozen_string_literal: true

class Component < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition'
  belongs_to :protocol_definition, class_name: 'ProtocolDefinition'
  belongs_to :phase_definition, class_name: 'PhaseDefinition'
  belongs_to :trial_definition, class_name: 'TrialDefinition'

  has_many :data_point, class_name: 'StudyResult::DataPoint', dependent: :destroy

  include Swagger::Blocks

  swagger_schema :ComponentDefinition do
    property :Inputs do
      key :type, :array
      items do # TODO: put actual schema here
        key :type, :integer
        key :format, :int64
      end
    end
    property :Outputs do
      key :type, :array
      items do # TODO: put actual schema here
        key :type, :integer
        key :format, :int64
      end
    end
  end
  swagger_schema :Component do
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
