# frozen_string_literal: true

class Apidocs::V1::TrialResultsApidocs
  include Swagger::Blocks

  swagger_path '/study_results/{study_result_id}/trial_results' do
    operation :get do
      key :summary, 'All TrialResults'
      key :description, 'Returns all TrialResult results the user has access to'
      key :operationId, 'findTrialResults'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'TrialResult', 'Study Results'
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
        key :name, :experiment_id
        key :in, :query
        key :description, 'ID for the experiment whose TrialResults to return'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :query
        key :description, 'ID for the phase definition whose TrialResults to return'
        key :required, false
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
        key :description, 'TrialResults response'
        schema do
          key :type, :array
          items do
            key :'$ref', :TrialResult
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
      key :summary, 'New TrialResult'
      key :description, 'Creates a new TrialResult'
      key :operationId, 'addTrialResult'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'TrialResult', 'Study Results'
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
        key :name, :trial_result
        key :in, :body
        key :description, 'Trial definition to add to the store'
        key :required, true
        schema do
          key :'$ref', :TrialResultInput
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
        key :description, 'trial definition response'
        schema do
          key :'$ref', :TrialResult
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
  swagger_path '/study_results/{study_result_id}/trial_results/{id}' do
    operation :put do
      key :description, 'Updates a TrialResult result'
      key :summary, 'Updates a TrialResult result'
      key :operationId, 'updateTrialResult'
      key :tags, [
        'TrialResult', 'Study Results'
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
        key :description, 'ID of trial definition to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Trial Definition Object'
        schema do
          key :'$ref', :TrialResult
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
  swagger_path '/study_results/{study_result_id}/trial_results/{id}' do
    operation :delete do
      key :description, 'Deletes a TrialResult result'
      key :summary, 'Deletes a TrialResult result'
      key :operationId, 'deleteTrialResult'
      key :tags, [
        'TrialResult', 'Study Results'
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
        key :description, 'ID of trial definition to fetch'
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

  swagger_schema :TrialResultInput do
    key :required, [:trial_result]
    property :trial_result do
      key :'$ref', :TrialResult
    end
  end

  swagger_schema :TrialResult do
    key :required, %i[experiment_id phase_definition_id trial_definition_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :experiment_id do
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
    property :session_name do
      key :type, :string
    end
    property :started_at do
      key :type, :string
      key :format, :"date-time"
    end
    property :completed_at do
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
