# frozen_string_literal: true

module Apidocs
  module V1
    class PhaseDefinitionsApidocs
      include Swagger::Blocks

      swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions' do
        operation :get do
          key :summary, 'All Phase Definitions'
          key :description, 'Returns all study definitions from the system to which the user has access'
          key :operationId, 'findPhaseDefinitions'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Phase Definition', 'Study Creation'
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
            key :description, 'Array of PhaseDefinition objects matching the query'
            schema do
              key :type, :array
              items do
                key :'$ref', :PhaseDefinition
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
          key :summary, 'New Phase Definition'
          key :description, 'Creates a new phase definition'
          key :operationId, 'addPhaseDefinition'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Phase Definition', 'Study Creation'
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
            key :name, :phase_definition
            key :in, :body
            key :description, 'Phase definition to add to the store'
            key :required, true
            schema do
              key :'$ref', :PhaseDefinitionInput
            end
          end
          parameter do
            key :name, :study_definition_id
            key :in, :path
            key :description, 'Study definition id which this phase definition is added to'
            key :required, true
            key :type, :string
          end
          parameter do
            key :name, :protocol_definition_id
            key :in, :path
            key :description, 'Protocol definition id which this phase definition is added to'
            key :required, true
            key :type, :string
          end
          response 201 do
            key :description, 'phase definition response'
            schema do
              key :'$ref', :PhaseDefinition
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

      # Update Phase Definition Object
      swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{id}' do
        operation :put do
          key :description, 'Updates a Phase Definition'
          key :summary, 'Updates a Phase Definition'
          key :operationId, 'updatePhaseDefinition'
          key :tags, [
            'Phase Definition', 'Study Creation'
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
            key :description, 'ID of phase definition to fetch'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :study_definition
            key :in, :body
            key :description, 'Phase Definition object to update'
            key :required, true
            schema do
              key :'$ref', :PhaseDefinition
            end
          end

          response 200 do
            key :description, 'Updated Phase Definition object'
            schema do
              key :'$ref', :PhaseDefinition
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

      # Delete Phase Definition Object
      swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{id}' do
        operation :delete do
          key :description, 'Deletes a Phase Definition'
          key :summary, 'Deletes a Phase Definition'
          key :operationId, 'deletePhaseDefinition'
          key :tags, [
            'Phase Definition', 'Study Creation'
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
            key :description, 'ID of phase definition to delete'
            key :required, true
            key :type, :integer
            key :format, :int64
          end

          response 204 do
            key :description, 'Successful Response; phase defnition deleted (No Content)'
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

      swagger_schema :PhaseDefinitionInput do
        key :required, [:phase_definition]
        property :phase_definition do
          key :'$ref', :PhaseDefinition
        end
      end
    end
  end
end
