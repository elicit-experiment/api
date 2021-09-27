# frozen_string_literal: true

module Apidocs
  module V1
    class TimeSeriesApidocs
      include Swagger::Blocks

      swagger_path '/study_results/{study_result_id}/time_series' do
        operation :get do
          key :summary, 'All time series'
          key :description, 'Returns all time series from the system to which the user has access'
          key :operationId, 'findTimeSeries'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Study Results', 'Time Series'
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
            key :name, :stage_id
            key :in, :query
            key :description, 'Stage results id of the experiment results to return'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :protocol_user_id
            key :in, :query
            key :description, 'Protocol user id for the queries time series'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :phase_definition_id
            key :in, :query
            key :description, 'Phase definition id for the queries time series'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :trial_definition_id
            key :in, :query
            key :description, 'Trial definition id for the queries time series'
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :component_id
            key :in, :query
            key :description, 'Component definition id for the queries time series'
            key :required, false
            key :type, :integer
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
            key :description, 'time_series response'
            schema do
              key :type, :array
              items do
                key :'$ref', :TimeSeries
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
          key :summary, 'New Time Series'
          key :description, 'Creates a time Series'
          key :operationId, 'addTimeSeries'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Study Results', 'Time Series'
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
            key :name, :time_series
            key :in, :body
            key :description, 'Time Series to add to the store'
            key :required, true
            schema do
              key :'$ref', :TimeSeriesInput
            end
          end
          response 201 do
            key :description, 'time Series response'
            schema do
              key :'$ref', :TimeSeries
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

      # Get Time Series Object Content
      swagger_path '/study_results/time_series/{id}/content' do
        operation :get do
          key :summary, 'Get Time Series Content'
          key :description, 'Gets the content of a time Series'
          key :operationId, 'getTimeSeriesContent'
          key :produces, [
            'application/text'
          ]
          key :tags, [
            'Study Results', 'Time Series'
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
            key :name, :id
            key :in, :path
            key :description, 'ID of time series to get'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :username
            key :in, :query
            key :description, 'Filter by username'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :groupname
            key :in, :query
            key :description, 'Filter by groupname'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :study_definition_id
            key :in, :query
            key :description, 'Filter by study definition'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :protocol_definition_id
            key :in, :query
            key :description, 'Filter by protocol definition'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :phase_definition_id
            key :in, :query
            key :description, 'Filter by phase definition'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :trial_definition_id
            key :in, :query
            key :description, 'Filter by trial definition'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :component_id
            key :in, :query
            key :description, 'Filter by component definition'
            key :required, false
            key :type, :string
          end
          response 200 do
            key :description, 'time Series response'
          end
          response :default do
            key :description, 'unexpected error'
            schema do
              key :'$ref', :ElicitError
            end
          end
        end
      end

      # Get Time Series Object
      swagger_path '/study_results/time_series/{id}' do
        operation :get do
          key :summary, 'Get Time Series'
          key :description, 'Gets a time Series'
          key :operationId, 'getTimeSeries'
          key :produces, [
            'application/json'
          ]
          key :tags, [
            'Study Results', 'Time Series'
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
            key :name, :id
            key :in, :path
            key :description, 'ID of time series to get'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :username
            key :in, :query
            key :description, 'Filter by username'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :groupname
            key :in, :query
            key :description, 'Filter by groupname'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, :study_definition_id
            key :in, :query
            key :description, 'Filter by study definition'
            key :required, false
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :protocol_definition_id
            key :in, :query
            key :description, 'Filter by protocol definition'
            key :required, false
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :phase_definition_id
            key :in, :query
            key :description, 'Filter by phase definition'
            key :required, false
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :trial_definition_id
            key :in, :query
            key :description, 'Filter by trial definition'
            key :required, false
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :component_id
            key :in, :query
            key :description, 'Filter by component definition'
            key :required, false
            key :type, :integer
            key :format, :int64
          end

          response 200 do
            key :description, 'time Series response'
            schema do
              key :'$ref', :TimeSeries
            end
          end
          response :default do
            key :description, 'unexpected error'
            schema do
              key :'$ref', :ElicitError
            end
          end
        end

        operation :put do
          key :description, 'Updates a Time Series'
          key :summary, 'Updates a Time Series'
          key :operationId, 'updateTimeSeries'
          key :tags, [
            'Study Results', 'Time Series'
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
            key :description, 'ID of time Series to fetch'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :time_series
            key :in, :body
            key :description, 'Time Series Object to update'
            key :required, true
            schema do
              key :'$ref', :TimeSeries
            end
          end

          response 200 do
            key :description, 'Time Series Object'
            schema do
              key :'$ref', :TimeSeries
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

      # Delete Time Series Object
      swagger_path '/study_results/time_series/{id}' do
        operation :delete do
          key :description, 'Deletes a Time Series'
          key :summary, 'Deletes a Time Series'
          key :operationId, 'deleteTimeSeries'
          key :tags, [
            'Study Results', 'Time Series'
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

      swagger_schema :TimeSeriesInput do
        key :required, [:time_series]
        property :time_series do
          key :'$ref', :TimeSeries
        end
      end

      swagger_schema :TimeSeries do
        key :required, [:study_definition_id]
        property :id do
          key :type, :integer
          key :format, :int64
        end
        property :stage_id do
          key :type, :integer
          key :format, :int64
        end
        property :study_definition_id do
          key :type, :integer
          key :format, :int64
        end
        property :protocol_definition_id do
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
        property :file do
          key :type, :string
        end
        property :schema do
          key :type, :string
        end
        property :schema_metadata do
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
        property :completed_at do
          key :type, :string
          key :format, :"date-time"
        end
      end
    end
  end
end
