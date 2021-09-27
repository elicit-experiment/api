# frozen_string_literal: true

module Apidocs
  module V1
    class ProtocolDefinitionsApidocs
      include Swagger::Blocks

      swagger_path '/study_definitions/{study_definition_id}/protocol_definitions' do
        operation :get do
          key :summary, 'All Protocol Definitions'
          key :description, 'Returns all protocol definitions from the system to which the user has access'
          key :operationId, 'findProtocolDefinitions'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Protocol Definition', 'Study Creation'
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
            key :description, 'Array of ProtocolDefinition objects matching the query'
            schema do
              key :type, :array
              items do
                key :'$ref', :ProtocolDefinition
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
          key :operationId, 'addProtocolDefinition'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Protocol Definition', 'Study Creation'
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
            key :name, :protocol_definition
            key :in, :body
            key :description, 'Protocol definition to add to the store'
            key :required, true
            schema do
              key :'$ref', :ProtocolDefinitionInput
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
            key :description, 'Newly-added protcol definition'
            schema do
              key :'$ref', :ProtocolDefinition
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
      swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{id}' do
        operation :put do
          key :description, 'Updates a Protocol Definition'
          key :summary, 'Updates a Protocol Definition'
          key :operationId, 'updateProtocolDefinition'
          key :tags, [
            'Protocol Definition', 'Study Creation'
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
            key :description, 'ID of protocol definition to update'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :study_definition
            key :in, :body
            key :description, 'Protocol Definition object to update'
            key :required, true
            schema do
              key :'$ref', :ProtocolDefinition
            end
          end

          response 200 do
            key :description, 'Newly-updated protocol definition object'
            schema do
              key :'$ref', :ProtocolDefinition
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
      swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{id}' do
        operation :delete do
          key :description, 'Deletes a Protocol Definition'
          key :summary, 'Deletes a Protocol Definition'
          key :operationId, 'deleteProtocolDefinition'
          key :tags, [
            'Protocol Definition', 'Study Creation'
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
            key :description, 'ID of protocol definition to delete'
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

      swagger_schema :ProtocolDefinitionInput do
        key :required, [:protocol_definition]
        property :protocol_definition do
          key :'$ref', :ProtocolDefinition
        end
      end
    end
  end
end
