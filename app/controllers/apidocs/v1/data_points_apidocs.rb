# frozen_string_literal: true

module Apidocs
  module V1
    class DataPointsApidocs
      include Swagger::Blocks

      swagger_path '/study_results/{study_result_id}/data_points' do
        operation :get do
          key :summary, 'Query data points'
          key :description, 'Returns all data points from the study/protocol/phase/trial to which the user has access'
          key :operationId, 'findDataPoints'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Data Point', 'Study Results'
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
            key :name, :study_result_id
            key :in, :path
            key :description, 'Study results id of the experiment results to return'
            key :required, true
            key :type, :string
          end
          parameter do
            key :name, :protocol_user_id
            key :in, :query
            key :description, 'Protocol user id for the queries data points'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :phase_definition_id
            key :in, :query
            key :description, 'Phase definition id for the queries data points'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :trial_definition_id
            key :in, :query
            key :description, 'Trial definition id for the queries data points'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :component_id
            key :in, :query
            key :description, 'Component definition id for the queries data points'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :page_size
            key :in, :query
            key :description, 'Return page size (defaults to 100)'
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
            key :description, 'Results of query: all DataPoint objects matching query parameters'
            schema do
              key :type, :array
              items do
                key :'$ref', :DataPoint
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
      end

      swagger_path '/study_results/{study_result_id}/data_points' do
        operation :post do
          key :summary, 'New DataPoint'
          key :description, 'Creates a new data_point'
          key :operationId, 'addDataPoint'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Data Point', 'Study Results'
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
            key :name, :data_point
            key :in, :body
            key :description, 'DataPoint definition to add to the store'
            key :required, true
            schema do
              key :'$ref', :DataPointInput
            end
          end
          parameter do
            key :name, :study_result_id
            key :in, :path
            key :description, 'Study results id of the experiment results to return'
            key :required, true
            key :type, :string
          end

          response 201 do
            key :description, 'Newly-created data point object'
            schema do
              key :'$ref', :DataPoint
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

      # Update DataPoint Definition Object
      swagger_path '/study_results/{study_result_id}/trial_definitions/{trial_definition_id}/data_points/{id}' do
        operation :put do
          key :description, 'Updates a DataPoint Definition'
          key :summary, 'Updates a DataPoint Definition'
          key :operationId, 'updateDataPoint'
          key :tags, [
            'Data Point', 'Study Results'
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
            key :description, 'ID of data_point to fetch'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :study_result_id
            key :in, :path
            key :description, 'Study results id of the experiment results to return'
            key :required, true
            key :type, :string
          end
          response 200 do
            key :description, 'DataPoint Definition Object'
            schema do
              key :'$ref', :DataPoint
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

      # Delete DataPoint Definition Object
      swagger_path '/study_results/{study_result_id}/trial_definitions/{trial_definition_id}/data_points/{id}' do
        operation :delete do
          key :description, 'Deletes a DataPoint Definition'
          key :summary, 'Deletes a DataPoint Definition'
          key :operationId, 'deleteDataPoint'
          key :tags, [
            'Data Point', 'Study Results'
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
            key :name, :study_result_id
            key :in, :path
            key :description, 'Study results id of the experiment results to return'
            key :required, true
            key :type, :string
          end
          parameter do
            key :name, :id
            key :in, :path
            key :description, 'ID of data point to delete'
            key :required, true
            key :type, :integer
            key :format, :int64
          end

          response 204 do
            key :description, 'Successful Response; data point deleted (No Content)'
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

      swagger_schema :DataPointInput do
        key :required, [:data_point]
        property :data_point do
          key :'$ref', :DataPoint
        end
      end

      swagger_schema :DataPoint do
        key :required, %i[stage_id protocol_user_id phase_definition_id trial_definition_id component_id]
        property :stage_id do
          key :type, :integer
          key :format, :int64
        end
        property :protocol_user_id do
          key :type, :integer
          key :format, :int64
        end
        property :phase_definition_id do
          key :type, :integer
          key :format, :int64
        end
        property :trial_definition_id do
          key :type, :integer
          key :format, :int64
        end
        property :component_id do
          key :type, :integer
          key :format, :int64
        end
        property :component_name do
          key :type, :string
        end
        property :kind do
          key :type, :string
        end
        property :entity_type do
          key :type, :string
        end
        property :point_type do
          key :type, :string
        end
        property :value do
          key :type, :string
        end
        property :method do
          key :type, :string
        end
        property :created_at do
          key :type, :string
          key :format, :"date-time"
        end
        property :updated_at do
          key :type, :string
          key :format, :"date-time"
        end
        property :datetime do
          key :type, :string
          key :format, :"date-time"
        end
      end
    end
  end
end
