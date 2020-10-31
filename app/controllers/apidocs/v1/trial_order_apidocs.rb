# frozen_string_literal: true

class Apidocs::V1::TrialOrderApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_order' do
    operation :post do
      key :summary, 'New Trial Order'
      key :description, 'Creates a new trial order'
      key :operationId, 'addTrialOrder'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Trial Order', 'Study Creation'
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
        key :name, :trial_order
        key :in, :body
        key :description, 'Trial order to add to the store'
        key :required, true
        schema do
          key :'$ref', :TrialOrderInput
        end
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study definition id which this trial order is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this trial order is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phase_definition_id
        key :in, :path
        key :description, 'Phase definition id which this trial order is added to'
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
      response 201 do
        key :description, 'trial order response'
        schema do
          key :'$ref', :TrialOrder
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

  # Update Trial Order Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_definitions/{phase_definition_id}/trial_order' do
    operation :put do
      key :description, 'Updates a Trial Order'
      key :summary, 'Updates a Trial Order'
      key :operationId, 'updateTrialOrder'
      key :tags, [
        'Trial Order', 'Study Creation'
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
        key :description, 'ID of trial order to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition
        key :in, :body
        key :description, 'Trial Order Object to update'
        key :required, true
        schema do
          key :'$ref', :TrialOrder
        end
      end

      response 200 do
        key :description, 'Trial Order Object'
        schema do
          key :'$ref', :TrialOrder
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

  swagger_schema :TrialOrderInput do
    key :required, [:trial_order]
    property :trial_order do
      key :'$ref', :TrialOrder
    end
  end
end
