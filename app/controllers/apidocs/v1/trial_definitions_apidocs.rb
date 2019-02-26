class Apidocs::V1::TrialDefinitionsApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions' do
    operation :get do
      key :summary, 'All Trial Definitions'
      key :description, 'Returns all trial definitions for the given study/protocol/phase to which the user has access'
      key :operationId, 'findTrialDefinitions'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Trial Definition', 'Study Creation'
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
        key :name, :page_size
        key :in, :query
        key :description, 'Return page size (defaults to 20)'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :page
        key :in, :query
        key :description, 'Return page number (defaults to 1)'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'Array of TrialDefinition objects matching the query'
        schema do
          key :type, :array
          items do
            key :'$ref', :TrialDefinition
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
      key :summary, 'New Trial Definition'
      key :description, 'Creates a new trial definition'
      key :operationId, 'addTrialDefinition'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Trial Definition', 'Study Creation'
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
        key :name, :trial_definition
        key :in, :body
        key :description, 'Trial definition to add to the store'
        key :required, true
        schema do
          key :'$ref', :TrialDefinitionInput
        end
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this trial definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this trial definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this trial definition is added to'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'Newly-created trial definition'
        schema do
          key :'$ref', :TrialDefinition
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

  # Update Trial Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{id}' do
    operation :put do
      key :description, 'Updates a Trial Definition'
      key :summary, 'Updates a Trial Definition'
      key :operationId, 'updateTrialDefinition'
      key :tags, [
        'Trial Definition', 'Study Creation'
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
        key :description, 'ID of trial definition to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :trial_definition
        key :in, :body
        key :description, 'Trial Definition object to update'
        key :required, true
        schema do
          key :'$ref', :TrialDefinition
        end
      end

      response 200 do
        key :description, 'Trial Definition Object'
        schema do
          key :'$ref', :TrialDefinition
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

  # Delete Trial Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{id}' do
    operation :delete do
      key :description, 'Deletes a Trial Definition'
      key :summary, 'Deletes a Trial Definition'
      key :operationId, 'deleteTrialDefinition'
      key :tags, [
        'Trial Definition', 'Study Creation'
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

  swagger_schema :TrialDefinitionInput do
    key :required, [:trial_definition]
    property :trial_definition do
      key :'$ref', :TrialDefinition
    end
  end
end
