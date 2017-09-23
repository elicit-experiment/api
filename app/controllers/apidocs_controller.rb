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
      key :name, 'study_definitions'
      key :description, 'Study Definition Operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://swagger.io'
      end
    end
    key :host, 'petstore.swagger.wordnik.com'
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    Apidocs::V1::StudyDefinitionsApidocs,
    Apidocs::V1::UsersApidocs,
    Apidocs::V1::AuthenticationApidocs,
    StudyDefinition,
    ErrorModel,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
