class Apidocs::V1::PhaseOrderApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_order' do
    operation :post do
      key :summary, 'New Phase Order'
      key :description, 'Creates a new phase order'
      key :operationId, 'addPhaseOrder'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'phase_order'
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
        key :name, :phase_order
        key :in, :body
        key :description, 'Phase order to add to the store'
        key :required, true
        schema do
          key :'$ref', :PhaseOrderInput
        end
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, 'Study order id which this phase order is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol order id which this phase order is added to'
        key :required, true
        key :type, :string
      end
      response 201 do
        key :description, 'phase order response'
        schema do
          key :'$ref', :PhaseOrder
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

  # Update Phase Order Object
  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/phase_order' do
    operation :put do
      key :description, 'Updates a Phase Order'
      key :summary, 'Updates a Phase Order'
      key :operationId, 'updatePhaseOrder'
      key :tags, [
        'phase_order'
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
        key :name, :phase_order
        key :in, :body
        key :description, 'Phase Order Object to update'
        key :required, true
        schema do
          key :'$ref', :PhaseOrder
        end
      end

      response 200 do
        key :description, 'Phase Order Object'
        schema do
          key :'$ref', :PhaseOrder
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

  swagger_schema :PhaseOrderInput do
    key :required, [:phase_order]
    property :phase_order do
      key :'$ref', :PhaseOrderInputBody
    end
  end

  swagger_schema :PhaseOrderInputBody do
    key :required, [:sequence_data, :name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :sequence_data do
      key :type, :string
    end
  end

end
