class Apidocs::V1::ComponentsApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/components' do
    operation :get do
      key :summary, 'All Component Definitions'
      key :description, 'Returns all study definitions from the system that the user has access to'
      key :operationId, 'findComponents'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'components'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated Users's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      response 200 do
        key :description, 'components response'
        schema do
          key :type, :array
          items do
            key :'$ref', :Component
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
      key :summary, 'New Component Definition'
      key :description, 'Creates a new component definition'
      key :operationId, 'addComponent'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'components'
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
        key :name, :component
        key :in, :body
        key :description, 'Component definition to add to the store'
        key :required, true
        schema do
          key :'$ref', :ComponentInput
        end
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this component definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this component definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this component definition is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id which this component definition is added to'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'component definition response'
        schema do
          key :'$ref', :Component
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

  # Update Component Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/components/{id}' do
    operation :put do
      key :description, 'Updates a Component Definition'
      key :summary, 'Updates a Component Definition'
      key :operationId, 'updateComponent'
      key :tags, [
        'components'
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
        key :description, 'ID of component definition to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition
        key :in, :body
        key :description, 'Component Definition Object to update'
        key :required, true
        schema do
          key :'$ref', :Component
        end
      end

      response 200 do
        key :description, 'Component Definition Object'
        schema do
          key :'$ref', :Component
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

  # Delete Component Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/components/{id}' do
    operation :delete do
      key :description, 'Deletes a Component Definition'
      key :summary, 'Deletes a Component Definition'
      key :operationId, 'deleteComponent'
      key :tags, [
        'components'
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

  swagger_schema :ComponentInput do
    key :required, [:component]
    property :component do
      key :'$ref', :ComponentInputBody
    end
  end

  swagger_schema :ComponentInputBody do
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
