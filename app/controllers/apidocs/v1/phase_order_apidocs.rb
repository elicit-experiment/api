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
        'Phase Order', 'Study Creation'
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
        key :description, 'Study definition id which this phase order is added to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, 'Protocol definition id which this phase order is added to'
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
        key :description, 'Newly created PhaseOrder object'
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
        'Phase Order', 'Study Creation'
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
        key :description, 'Phase Order object to update'
        key :required, true
        schema do
          key :'$ref', :PhaseOrder
        end
      end

      response 200 do
        key :description, 'Updated Phase Order object'
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
      key :'$ref', :PhaseOrder
    end
  end
end
