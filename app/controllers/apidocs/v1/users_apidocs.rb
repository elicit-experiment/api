class Apidocs::V1::UsersApidocs
  include Swagger::Blocks

  swagger_path '/users' do
    operation :get do
      key :description, 'Returns a List of Users'
      key :summary, 'Returns a List of Users'
      key :tags, [
        'Users'
      ]
      response 200 do
        key :description, 'User Object'
        schema do
          key :type, :array
          items do
            key :'$ref', :UserResponseObject
          end
        end
      end
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated Users's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end
      parameter do
        key :name, :query
        key :in, :query
        key :description, 'Username/Email filter'
        key :type, :string
        key :required, true
      end
      response :default do
        key :description, 'Returned when an unexpected error occurs'
        schema do
          key :'$ref', :ElicitError
        end
      end
    end
  end


  swagger_path '/users' do
    operation :post do
      key :description, 'Creates new User'
      key :summary, 'Creates new User'
      key :tags, [
        'Users'
      ]
      response 200 do
        key :description, 'User Object'
        schema do
          key :'$ref', :UserResponseObject
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
        key :name, :user
        key :in, :body
        key :description, 'User Object to create'
        key :required, true
        schema do
          key :'$ref', :UserObject
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

  swagger_path '/users' do
    operation :put do
      key :description, 'Updates Authenticated User'
      key :summary, 'Updates Authenticated User'
      key :tags, [
        'Users'
      ]
      response 200 do
        key :description, 'User Object'
        schema do
          key :'$ref', :UserResponseObject
        end
      end
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated User's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
      end

      parameter do
        key :name, :user
        key :in, :body
        key :description, 'User object containing attributes to update'
        key :required, true
        schema do
          key :'$ref', :UserObject
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

  swagger_path '/users/{id}' do
    operation :get do
      key :description, "Returns User's Profile"
      key :summary, "Returns User's Profile"
      key :tags, [
        'Users'
      ]
      response 200 do
        key :description, 'User Object'
        schema do
          key :'$ref', :User
        end
      end
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
        key :description, "User's ID"
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



  swagger_path '/users/current' do
    operation :get do
      key :description, "Returns Authenticated User's Profile"
      key :summary, "Returns Authenticated User's Profile"
      key :tags, [
        'Users', 'Authentication'
      ]
      response 200 do
        key :description, 'User Object'
        schema do
          key :'$ref', :User
        end
      end
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated User's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
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
  swagger_schema :UserObject do
    property :user do
      key :required, [:email, :password]
      property :username do
        key :type, :string
      end
      property :email do
        key :type, :string
      end
      property :password do
        key :type, :string
        key :example, 'specify password'
      end
      property :password_confirmation do
        key :type, :string
      end
    end
  end

  swagger_schema :UserResponseObject do
    property :id do
      key :type, :string
    end
    property :username do
      key :type, :string
    end
  end


end