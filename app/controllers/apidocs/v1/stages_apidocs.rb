class Apidocs::V1::StagesApidocs
  include Swagger::Blocks

  swagger_path '/study_results/{study_results_id}/stages' do
    operation :get do
      key :summary, 'All stages'
      key :description, 'Returns all stage results the user has access to'
      key :operationId, 'findStages'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Stage', 'Study Results'
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
        key :name, :study_results_id
        key :in, :path
        key :description, 'Study results id of the experiment results to return'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :experiment_id
        key :in, :query
        key :description, 'ID for the experiment whose stages to return'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :query
        key :description, 'ID for the phase definition whose stages to return'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'stages response'
        schema do
          key :type, :array
          items do
            key :'$ref', :Stage
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
      key :summary, 'New stage'
      key :description, 'Creates a new stage'
      key :operationId, 'addStage'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Stage', 'Study Results'
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
        key :name, :stage
        key :in, :body
        key :description, 'Trial definition to add to the store'
        key :required, true
        schema do
          key :'$ref', :StageInput
        end
      end
      parameter do
        key :name, :study_results_id
        key :in, :path
        key :description, 'Study results id of the experiment results to return'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :experiment_id
        key :in, :query
        key :description, 'ID for the experiment whose stages to return'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :query
        key :description, 'ID for the phase definition whose stages to return'
        key :required, false
        key :type, :string
      end
      response 201 do
        key :description, 'trial definition response'
        schema do
          key :'$ref', :Stage
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
  swagger_path '/study_results/{study_results_id}/stages/{id}' do
    operation :put do
      key :description, 'Updates a stage result'
      key :summary, 'Updates a stage result'
      key :operationId, 'updateStage'
      key :tags, [
        'Stage', 'Study Results'
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
        key :name, :study_results_id
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
          key :'$ref', :Stage
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
  swagger_path '/study_results/{study_results_id}/stages/{id}' do
    operation :delete do
      key :description, 'Deletes a stage result'
      key :summary, 'Deletes a stage result'
      key :operationId, 'deleteStage'
      key :tags, [
        'Stage', 'Study Results'
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
        key :name, :study_results_id
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

  swagger_schema :StageInput do
    key :required, [:stage]
    property :stage do
      key :'$ref', :Stage
    end
  end

  swagger_schema :Stage do
    key :required, [:experiment_id, :phase_definition_id, :id]
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
    property :completed_at do
      key :type, :string
      key :format, :datetime
    end
    property :last_completed_trial do
      key :type, :integer
      key :format, :int64
    end
    property :num_trials do
      key :type, :integer
      key :format, :int64
    end
    property :current_trial do
      key :type, :integer
      key :format, :int64
    end
    property :context_id do
      key :type, :integer
      key :format, :int64
    end
  end

end
