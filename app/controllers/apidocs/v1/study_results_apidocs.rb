class Apidocs::V1::StudyResultsApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/study_results' do
    operation :get do
      key :summary, 'All study results'
      key :description, 'Returns all study results from the system to which the user has access'
      key :operationId, 'findStudyResults'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Study Result', 'Study Results'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated Users's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this protocol definition is added to'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'study_results response'
        schema do
          key :type, :array
          items do
            key :'$ref', :StudyResult
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
      key :summary, 'New Protocol Definition'
      key :description, 'Creates a new protocol definition'
      key :operationId, 'addStudyResult'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Study Result', 'Study Results'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated Users's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :study_result
        key :in, :body
        key :description, 'Study result to add to the store'
        key :required, true
        schema do
          key :'$ref', :StudyResultInput
        end
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this protocol definition is added to'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'protocol definition response'
        schema do
          key :'$ref', :StudyResult
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

  # Update Protocol Definition Object
  swagger_path '/study_definitions/{study_definition_id}/study_results/{id}' do
    operation :put do
      key :description, 'Updates a Protocol Definition'
      key :summary, 'Updates a Protocol Definition'
      key :operationId, 'updateStudyResult'
      key :tags, [
        'Study Result', 'Study Results'
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
        key :description, 'ID of protocol definition to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition
        key :in, :body
        key :description, 'Protocol Definition Object to update'
        key :required, true
        schema do
          key :'$ref', :StudyResult
        end
      end

      response 200 do
        key :description, 'Protocol Definition Object'
        schema do
          key :'$ref', :StudyResult
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
          key :'$ref', :ElicitError
        end
      end
    end
  end

  # Delete Protocol Definition Object
  swagger_path '/study_definitions/{study_definition_id}/study_results/{id}' do
    operation :delete do
      key :description, 'Deletes a Protocol Definition'
      key :summary, 'Deletes a Protocol Definition'
      key :operationId, 'deleteStudyResult'
      key :tags, [
        'Study Result', 'Study Results'
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
        key :description, "Insufficient Scope (tip: ensure access_token was obtained with 'password' grant_type and user is an admin)"
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end

  swagger_schema :StudyResultInput do
    key :required, [:protocol_definition]
    property :study_result do
      key :'$ref', :StudyResult
    end
  end

  swagger_schema :StudyResult do
    key :required, [:study_definition_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :study_definition_id do
      key :type, :integer
      key :format, :int64
    end
    property :completed_at do
      key :type, :string
      key :format, :datetime
    end
  end

end
