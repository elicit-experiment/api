class Apidocs::V1::ProtocolUsersApidocs
  include Swagger::Blocks

  swagger_path '/study_definitions/{study_definition_id}/protocol_definitions/{protocol_definition_id}/users' do
    operation :get do
      key :description, 'Returns users who participate in this protocol'
      key :summary, 'Returns a List of ProtocolUsers'
      key :operationId, 'findProtocolUsers'
      key :tags, [
        'users'
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
      response 200 do
        key :description, 'ProtocolUser Object'
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
        'users'
      ]
      response 201 do
        key :description, 'ProtocolUser Object'
        schema do
          key :'$ref', :ProtocolUser
        end
      end
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated Client's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
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
      key :description, "Returns ProtocolUser's Profile"
      key :summary, "Returns ProtocolUser's Profile"
      key :tags, [
        'users'
      ]
      response 200 do
        key :description, 'ProtocolUser Object'
        schema do
          key :'$ref', :ProtocolUser
        end
      end
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
        'users'
      ]
      response 200 do
        key :description, 'ProtocolUser Object'
        schema do
          key :'$ref', :ProtocolUser
        end
      end
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
      property :protocol_definition_id do
        key :type, :integer
      end
    end
  end

end
