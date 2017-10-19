class Apidocs::V1::DataPointsApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/data_points' do
    operation :get do
      key :summary, 'All data points'
      key :description, 'Returns all data points from the study/protcol/phase/trial that the user has access to'
      key :operationId, 'queryDataPoints'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'study_results'
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
        key :in, :path
        key :description, 'Study definition id which this data_point is added to'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this data_point is added to'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :query
        key :description, 'Phase definition id which this data_point is added to'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :query
        key :description, 'Trial definition id which this data_point is added to'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'data_points response'
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


  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/data_points' do
    operation :get do
      key :summary, 'All data points'
      key :description, 'Returns all data points from the study/protcol/phase/trial that the user has access to'
      key :operationId, 'findDataPoints'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'study_results'
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
        key :in, :path
        key :description, 'Study definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'data_points response'
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

    operation :post do
      key :summary, 'New DataPoint'
      key :description, 'Creates a new data_point'
      key :operationId, 'addDataPoint'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'study_results'
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
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'data_point response'
        schema do
          key :'$ref', :DataPoint
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

  # Update DataPoint Definition Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/data_points/{id}' do
    operation :put do
      key :description, 'Updates a DataPoint Definition'
      key :summary, 'Updates a DataPoint Definition'
      key :operationId, 'updateDataPoint'
      key :tags, [
        'study_results'
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
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id which this data_point is added to'
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
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_definitions/{trial_definition_id}/data_points/{id}' do
    operation :delete do
      key :description, 'Deletes a DataPoint Definition'
      key :summary, 'Deletes a DataPoint Definition'
      key :operationId, 'deleteDataPoint'
      key :tags, [
        'study_results'
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
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this data_point is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :trial_definition_id
        key :in, :path
        key :description, 'Trial definition id which this data_point is added to'
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

  swagger_schema :DataPointInput do
    key :required, [:data_point]
    property :data_point do
      key :'$ref', :DataPoint
    end
  end

  swagger_schema :DataPoint do
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
