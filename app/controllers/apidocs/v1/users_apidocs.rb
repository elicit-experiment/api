# frozen_string_literal: true

module Apidocs
  module V1
    class UsersApidocs
      include Swagger::Blocks

      swagger_path '/users' do
        operation :get do
          key :description, 'Returns a list of users'
          key :summary, 'Returns a list of all users in the system'
          key :operationId, 'findUsers'
          key :tags, [
            'Users'
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
            key :name, :page_size
            key :in, :query
            key :description, 'Return page size (defaults to 100)'
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
          parameter do
            key :name, 'query'
            key :in, :query
            key :description, 'query by username or email substring'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, 'q[username]'
            key :in, :query
            key :description, 'query by username substring'
            key :required, false
            key :type, :string
          end
          parameter do
            key :name, 'q[email]'
            key :in, :query
            key :description, 'query by email substring'
            key :required, false
            key :type, :string
          end
          response 200 do
            key :description, 'Array of user objects matching the query'
            schema do
              key :type, :array
              items do
                key :'$ref', :UserResponseObject
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

      swagger_path '/users' do
        operation :post do
          key :description, 'Creates new User'
          key :summary, 'Creates new User'
          key :operationId, 'addUser'
          key :tags, [
            'Users'
          ]
          response 201 do
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
              key :'$ref', :UserInput
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
          key :operationId, 'updateUser'
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
              key :'$ref', :User
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
          key :description, 'Returns a specific user object'
          key :summary, 'Returns specific user object'
          key :operationId, 'findUser'
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
            key :type, :string
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
          key :description, "Returns authenticated user's user object"
          key :summary, "Returns the authenticated (i.e. the user whose access token is making the request) user's user object"
          key :operationId, 'getCurrentUser'
          key :tags, %w[
            Users Authentication
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

      swagger_schema :UserResponseObject do
        property :id do
          key :type, :string
        end
        property :username do
          key :type, :string
        end
      end

      swagger_schema :UserInput do
        key :required, [:user]
        property :user do
          key :'$ref', :UserDefinition
        end
      end
    end
  end
end
