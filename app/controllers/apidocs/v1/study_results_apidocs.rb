# frozen_string_literal: true

module Apidocs
  module V1
    class StudyResultsApidocs
      include Swagger::Blocks

      swagger_path '/study_results' do
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
            key :in, :query
            key :description, 'Study definition id for these results'
            key :required, true
            key :type, :string
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
          key :summary, 'New Study Result'
          key :description, 'Creates a study result'
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
          response 201 do
            key :description, 'study result response'
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

      # Update Study Result Object
      swagger_path '/study_results/{id}' do
        operation :put do
          key :description, 'Updates a Study Result'
          key :summary, 'Updates a Study Result'
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
            key :description, 'ID of study result to fetch'
            key :required, true
            key :type, :integer
            key :format, :int64
          end
          parameter do
            key :name, :study_definition
            key :in, :body
            key :description, 'Study Result Object to update'
            key :required, true
            schema do
              key :'$ref', :StudyResult
            end
          end

          response 200 do
            key :description, 'Study Result Object'
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

      # Delete Study Result Object
      swagger_path '/study_results/{id}' do
        operation :delete do
          key :description, 'Deletes a Study Result'
          key :summary, 'Deletes a Study Result'
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
        key :required, [:study_result]
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
        property :user_id do
          key :type, :integer
          key :format, :int64
        end
        property :completed_at do
          key :type, :string
          key :format, :"date-time"
        end
        property :started_at do
          key :type, :string
          key :format, :"date-time"
        end
        property :created_at do
          key :type, :string
          key :format, :"date-time"
        end
        property :updated_at do
          key :type, :string
          key :format, :"date-time"
        end
      end
    end
  end
end
