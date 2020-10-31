# frozen_string_literal: true

class Apidocs::V1::ComponentsApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/components/{component_id}' do
    operation :get do
      key :summary, 'Get single component'
      key :description, 'Returns a simple component matching the id'
      key :operationId, 'getComponent'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Component', 'Study Creation'
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
        key :name, :component_id
        key :in, :path
        key :description, 'ID of component definition to delete'
        key :required, true
        key :type, :integer
        key :format, :int64
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
        key :description, 'Array of Component objects matching the query'
        schema do
          key :'$ref', :Component
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/components/' do
    operation :get do
      key :summary, 'All component definitions'
      key :description, 'Returns all component definitions from the system to which the user has access'
      key :operationId, 'findComponents'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Component', 'Study Creation'
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
        key :description, 'Array of Component objects matching the query'
        schema do
          key :type, :array
          items do
            key :'$ref', :Component
          end
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end

    operation :post do
      key :summary, 'New component definition'
      key :description, 'Creates a new component definition'
      key :operationId, 'addComponent'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Component', 'Study Creation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated user's access token"
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
        key :description, 'Study definition id for the new component'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id for the new component'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id for the new component'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id for the new component'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'Newly-created component'
        schema do
          key :'$ref', :Component
        end
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end

  # Update Component Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/components/{id}' do
    operation :put do
      key :description, 'Update a component definition'
      key :summary, 'Updates a component definition'
      key :operationId, 'updateComponent'
      key :tags, [
        'Component', 'Study Creation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated user's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'ID of component definition to update'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :component_definition
        key :in, :body
        key :description, 'New component definition to update'
        key :required, true
        schema do
          key :'$ref', :Component
        end
      end

      response 200 do
        key :description, 'Component definition object'
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
      key :description, 'Delete a component definition'
      key :summary, 'Delete a component definition'
      key :operationId, 'deleteComponent'
      key :tags, [
        'Component', 'Study Creation'
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
        key :description, 'ID of component definition to delete'
        key :required, true
        key :type, :integer
        key :format, :int64
      end

      response 204 do
        key :description, 'Successful response; component deleted (No Content)'
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
      key :'$ref', :Component
    end
  end
end
