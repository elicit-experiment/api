class Apidocs::V1::ProtocolUsersApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/users' do
    operation :get do
      key :description, 'Returns users who participate in this protocol'
      key :summary, 'Returns a list of ProtocolUsers'
      key :operationId, 'findProtocolUsers'
      key :tags, [
        'Users', 'Study Creation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated user's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, "Study Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, "Protocol Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
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
        key :description, 'Array of protocol user objects'
        schema do
          key :type, :array
          items do
            key :'$ref', :ProtocolUser
          end
        end
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end


  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/users' do
    operation :post do
      key :description, 'Creates new ProtocolUser'
      key :summary, 'Creates new ProtocolUser'
      key :operationId, 'addProtocolUser'
      key :tags, [
        'Users', 'Study Creation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated Client's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, "Study Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, "Protocol Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :protocol_user
        key :in, :body
        key :description, 'ProtocolUser Object to create'
        key :required, true
        schema do
          key :'$ref', :ProtocolUserPostObject
        end
      end

      response 201 do
        key :description, 'Newly-created protocol user object'
        schema do
          key :'$ref', :ProtocolUser
        end
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end



  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/users/{user_id}' do
    operation :get do
      key :description, "Get ProtocolUser object for a specific user in the given protocol"
      key :summary, "Get ProtocolUser"
      key :tags, [
        'Users', 'Study Creation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated ProtocolUser's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :user_id
        key :in, :path
        key :description, "User's ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, "Study Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, "Protocol Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'ProtocolUser object for the given study/protcol'
        schema do
          key :'$ref', :ProtocolUser
        end
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/users/{user_id}' do
    operation :delete do
      key :description, "Delete a protocol user"
      key :summary, "Delete a protocol user"
      key :tags, [
        'Users', 'Study Creation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated ProtocolUser's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :user_id
        key :in, :path
        key :description, "User's ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :study_definition_id
        key :in, :path
        key :description, "Study Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :protocol_definition_id
        key :in, :path
        key :description, "Protocol Definition ID"
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 204 do
        key :description, 'Successful Response (No Content)'
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end


  # -----------------------
  # SCHEMAS
  # -----------------------
  swagger_schema :ProtocolUserPostObject do
    property :user do
      key :required, [:user_id, :protocol_definition_id]
      property :user_id do
        key :type, :integer
      end
      property :group_name do
        key :type, :string
      end
      property :protocol_definition_id do
        key :type, :integer
      end
    end
  end

end
