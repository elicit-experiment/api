class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'Elicit'
      key :description, 'The API for the Elicit app'
      key :termsOfService, 'http://tbd.com/terms/'
      contact do
        key :name, 'DTU CogSci'
      end
      license do
        key :name, 'MIT'
      end
    end
    tag do
      key :name, 'Study Creation'
      key :description, 'Operations to define studies'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Study Participation'
      key :description, 'Operations to participate in studies'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Study Definition'
      key :description, 'Study Definition operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Protocol Definition'
      key :description, 'Protocol Definition operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Phase Definition'
      key :description, 'Phase Definition operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Phase Order'
      key :description, 'Phase Order operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Trial Definition'
      key :description, 'Trial Definition operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Trial Order'
      key :description, 'Trial Order operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Component'
      key :description, 'Operations on components'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Stimulus'
      key :description, 'Operations on Stimuli'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Users'
      key :description, 'User operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Authentication'
      key :description, 'Authentication operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Study Results'
      key :description, 'Operations for getting the results of studies'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Study Result'
      key :description, 'Operations for StudyResult objects'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Experiment'
      key :description, 'Operations on Experiment objects'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Stage'
      key :description, 'Operations on Stage objects'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    tag do
      key :name, 'Data Point'
      key :description, 'Operations on Data Point objects'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://'
      end
    end
    key :host, ''#ENV['API_URL']
    key :basePath, '/api/v1'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    # Definition of studies
    Apidocs::V1::StudyDefinitionsApidocs,
    Apidocs::V1::ProtocolDefinitionsApidocs,
    Apidocs::V1::PhaseDefinitionsApidocs,
    Apidocs::V1::PhaseOrderApidocs,
    Apidocs::V1::TrialDefinitionsApidocs,
    Apidocs::V1::TrialOrderApidocs,
    Apidocs::V1::ComponentsApidocs,
    Apidocs::V1::StimuliApidocs,
    StudyDefinition,
    ProtocolDefinition,
    PhaseDefinition,
    PhaseOrder,
    TrialDefinition,
    TrialOrder,
    Component,
    Stimulus,

    # Results of studies
    Apidocs::V1::StudyResultsApidocs,
    Apidocs::V1::ExperimentsApidocs,
    Apidocs::V1::StagesApidocs,
    Apidocs::V1::TrialResultsApidocs,
    Apidocs::V1::DataPointsApidocs,
    Apidocs::V1::TimeSeriesApidocs,

    # Participating in Studies
    Apidocs::V1::ParticipantApidocs,

    # API infrastructure
    ElicitError,

    # Users & Auth
    Apidocs::V1::UsersApidocs,
    Apidocs::V1::AuthenticationApidocs,
    Apidocs::V1::ProtocolUsersApidocs,
    User,
    ProtocolUser,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
