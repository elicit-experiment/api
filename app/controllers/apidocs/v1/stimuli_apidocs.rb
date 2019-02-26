class Apidocs::V1::StimuliApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/stimuli' do
    operation :get do
      key :summary, 'All Stimulus Definitions'
      key :description, 'Returns all stimuli for the given study/protocol/phase/trial to which the user has access'
      key :operationId, 'findStimuli'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Stimulus', 'Study Creation'
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
        key :description, 'Array of Stimulus objects matching the query'
        schema do
          key :type, :array
          items do
            key :'$ref', :Stimulus
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
      key :summary, 'New Stimulus Definition'
      key :description, 'Creates a new stimulus definition'
      key :operationId, 'addStimulus'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Stimulus', 'Study Creation'
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
        key :name, :stimulus
        key :in, :body
        key :description, 'Stimulus definition to add to the store'
        key :required, true
        schema do
          key :'$ref', :StimulusInput
        end
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this stimulus definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this stimulus definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this stimulus definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id which this stimulus definition is added to'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'stimulus definition response'
        schema do
          key :'$ref', :Stimulus
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

  # Update Stimulus Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/stimuli/{id}' do
    operation :put do
      key :description, 'Updates a Stimulus Definition'
      key :summary, 'Updates a Stimulus Definition'
      key :operationId, 'updateStimulus'
      key :tags, [
        'Stimulus', 'Study Creation'
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
        key :description, 'ID of stimulus definition to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition
        key :in, :body
        key :description, 'Stimulus Definition Object to update'
        key :required, true
        schema do
          key :'$ref', :Stimulus
        end
      end

      response 200 do
        key :description, 'Stimulus Definition Object'
        schema do
          key :'$ref', :Stimulus
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

  # Delete Stimulus Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/stimuli/{id}' do
    operation :delete do
      key :description, 'Deletes a Stimulus Definition'
      key :summary, 'Deletes a Stimulus Definition'
      key :operationId, 'deleteStimulus'
      key :tags, [
        'Stimulus', 'Study Creation'
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

  swagger_schema :StimulusInput do
    key :required, [:stimulus]
    property :stimulus do
      key :'$ref', :StimulusInputBody
    end
  end

  swagger_schema :StimulusInputBody do
    key :required, [:definition_data, :name]
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
