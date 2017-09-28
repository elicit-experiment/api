class Apidocs::V1::StudyDefinitionsApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions' do
    operation :get do
      key :summary, 'All Study Definitions'
      key :description, 'Returns all study definitions from the system that the user has access to'
      key :operationId, 'findStudyDefinitions'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'study_definitions'
      ]
      response 200 do
        key :description, 'study_definitions response'
        schema do
          key :type, :array
          items do
            key :'$ref', :StudyDefinition
          end
        end
      end
      response :default do
        key :description, 'unexpected error'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end

    operation :post do
      key :summary, 'New Study Definition'
      key :description, 'Creates a new study definitions'
      key :operationId, 'addStudy'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'study_definitions'
      ]
      parameter do
        key :name, :study
        key :in, :body
        key :description, 'Study to add to the store'
        key :required, true
        schema do
          key :'$ref', :StudyDefinitionInput
        end
      end
      response 201 do
        key :description, 'study response'
        schema do
          key :'$ref', :StudyDefinition
        end
      end
      response :default do
        key :description, 'unexpected error'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end

  # Update Study Definition Object
  swagger_path '/study_definitions/{id}' do
    operation :put do
      key :description, 'Updates a Study Definition'
      key :summary, 'Updates a Study Definition'
      key :operationId, 'updateStudyDefinition'
      key :tags, [
        'study_definitions'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated User's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'ID of study definition to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition
        key :in, :body
        key :description, 'Study Definition Object to update'
        key :required, true
        schema do
          key :'$ref', :StudyDefinition
        end
      end

      response 200 do
        key :description, 'Study Definition Object'
        schema do
          key :'$ref', :StudyDefinitionResponse
        end
      end
      response 401 do
        key :description, 'Unauthorized Request'
      end
      response 403 do
        key :description, "Insufficient Scope (tip: ensure access_token was obtained with 'password' grant_type)"
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ErrorModel
        end
      end
    end
  end

  # Delete Study Definition Object
  swagger_path '/study_definitions/{id}' do
    operation :delete do
      key :description, 'Deletes a Study Definition'
      key :summary, 'Deletes a Study Definition'
      key :tags, [
        'study_definitions'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated User's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'ID of study definition to delete'
        key :required, true
        key :type, :integer
        key :format, :int64
      end

      response 204 do
        key :description, 'Successful Response (No Content)'
      end
      response 401 do
        key :description, 'Unauthorized Request'
      end
      response 403 do
        key :description, "Insufficient Scope (tip: ensure access_token was obtained with 'password' grant_type)"
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ErrorModel
        end
      end
    end
  end

  swagger_schema :StudyDefinitionInput do
    key :required, [:study_definition]
    property :study_definition do
      key :'$ref', :StudyDefinitionInputBody
    end
  end

  swagger_schema :StudyDefinitionInputBody do
    key :required, [:principal_investigator_user_id, :title]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :principal_investigator_user_id do
      key :type, :integer
      key :format, :int64
    end
  end

end
