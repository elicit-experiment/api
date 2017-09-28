module Apidocs::V1
  class AuthenticationApidocs
    include Swagger::Blocks

    # -----------------------------------------
    # ENDPONTS DOUCMENTATION
    # -----------------------------------------
    def self.apps_list_url
       "<a target='_new' href='#{Rails.application.routes.url_helpers.oauth_applications_url(:only_path => true)}'>Applications List</a>"
    end
    swagger_path '/oauth/token' do
      operation :post do
        key :description, 'Authenticate user credentials and returns an access token'
        key :summary, 'Authenticate a User OR Client App and Creates Access Token'
        key :operationId, 'getAuthToken'
        key :tags, [
          'Authentication'
        ]
        key :consumes, ['application/json']
        parameter do
          key :name, :auth_request
          key :in, :body
          key :description, 'parameters of auth request'
          key :required, true
          schema do
            key :'$ref', :AuthRequestInput
          end
        end

        response 200 do
          key :description, 'access token'
          schema do
            key :'$ref', :AccessToken
          end
        end
        response 401 do
          key :description, 'Unable to create access token'
          schema do
            key :'$ref', :ElicitError
          end
        end
      end
    end

    # -----------------------------------------
    # SCHEMAS
    # -----------------------------------------
    swagger_schema :AuthRequestInput do
      key :required, [:client_id, :client_secret,:grant_type]
      property :client_id do
        key :in, :formData
        key :description, "Application ID -- See #{AuthenticationApidocs::apps_list_url}"
        key :type, :string
        key :default, Rails.configuration.swagger_default_client_id
      end
      property :client_secret do
        key :description, "Application Secret -- See #{AuthenticationApidocs::apps_list_url}"
        key :type, :string
        key :default, Rails.configuration.swagger_default_client_secret
      end
      property :grant_type do
        key :description, "OAuth grant type, valid values: 'password' (for username/password login), 'client_credentials' (for initial client app authentication)"
        key :type, :string
        key :default, 'password'
      end
      property :email do
        key :description, "Email of user being authenticated (for 'password' grant_type)"
        key :type, :string
      end
      property :password do
        key :description, "Password of user being authenticated (for 'password' grant_type)"
        key :type, :string
      end
      property :refresh_token do
        key :description, "Refresh token (for 'refresh_token' grant_type only)"
        key :type, :string
      end
    end

    swagger_schema :AccessToken do
      key :required, [:access_token, :token_type,:expires_in,:created_at]
      property :expires_in do
        key :type, :integer
        key :format, :int32
      end
      property :created_at do
        key :type, :integer
        key :format, :int32
      end
      property :access_token do
        key :type, :string
      end
      property :scope do
        key :type, :string
      end
      property :token_type do
        key :type, :string
      end
      property :token_type do
        key :type, :string
      end
    end
  end
end