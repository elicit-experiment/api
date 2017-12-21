class Apidocs::V1::ExperimentsApidocs
  include Swagger::Blocks

  swagger_path '/study_results/{study_results_id}/experiments' do
    operation :get do
      key :summary, 'Returns all experiment results from the system to which the user has access'
      key :operationId, 'findExperiments'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Experiment', 'Study Results'
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
        key :name, :protocol_user_id
        key :in, :query
        key :description, 'Protocol definition id of the experiment results to return'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Array of experiment objects matching study/protocol ids'
        schema do
          key :type, :array
          items do
            key :'$ref', :Experiment
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
      key :summary, 'New experiment result'
      key :description, 'Creates a new experiment'
      key :operationId, 'addExperiment'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Experiment', 'Study Results'
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
        key :name, :experiment
        key :in, :body
        key :description, 'Exeriment result to add to the store'
        key :required, true
        schema do
          key :'$ref', :ExperimentInput
        end
      end
      parameter do
        key :name, :study_results_id
        key :in, :path
        key :description, 'Study results id of the experiment results to return'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'Newly-created experiment result object'
        schema do
          key :'$ref', :Experiment
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

  swagger_path '/study_results/{study_results_id}/experiments/{experiment_id}' do
    operation :put do
      key :description, 'Updates an experiment result'
      key :summary, 'Updates an experiment result'
      key :operationId, 'updateExperiment'
      key :tags, [
        'Experiment', 'Study Results'
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
        key :name, :experiment_id
        key :in, :path
        key :description, 'Experiment id of the experiment to update'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :experiment
        key :in, :body
        key :description, 'Experiment result object to update'
        key :required, true
        schema do
          key :'$ref', :Experiment
        end
      end

      response 200 do
        key :description, 'Updated experiment result object'
        schema do
          key :'$ref', :Experiment
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

  # Delete Experiment result Object
  swagger_path '/study_results/{study_results_id}/experiments/{experiment_id}' do
    operation :delete do
      key :description, 'Deletes an experiment'
      key :summary, 'Deletes an experiment'
      key :operationId, 'deleteExperiment'
      key :tags, [
        'Experiment', 'Study Results'
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
        key :name, :experiment_id
        key :in, :path
        key :description, 'Experiment id of the experiment to delete'
        key :required, true
        key :type, :string
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

  swagger_schema :ExperimentInput do
    key :required, [:experiment]
    property :experiment do
      key :'$ref', :Experiment
    end
  end

  swagger_schema :Experiment do
    property :id do
      key :type, :integer
      key :format, :int64
    end 
    property :study_result_id do
      key :type, :integer
      key :format, :int64
    end
    property :protocol_user_id do
      key :type, :integer
      key :format, :int64
    end
    property :current_stage_id do
      key :type, :integer
      key :format, :int64
    end
    property :num_stages_completed do
      key :type, :integer
      key :format, :int64
    end
    property :num_stages_remaining do
      key :type, :integer
      key :format, :int64
    end
#    property :started_at do
#      key :type, :string
#      key :format, :datetime
#    end
#    property :completed_at do
#      key :type, :string
#      key :format, :datetime
#    end
  end

end
