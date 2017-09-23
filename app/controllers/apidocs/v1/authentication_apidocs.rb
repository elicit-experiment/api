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
        key :tags, [
          'Authentication'
        ]
        key :consumes, ['application/x-www-form-urlencoded']
        parameter do
          key :name, :client_id
          key :in, :formData
          key :description, "Application ID -- See #{AuthenticationApidocs::apps_list_url}"
          key :required, true
          key :type, :string
          key :default, Rails.configuration.swagger_default_client_id
        end
        parameter do
          key :name, :client_secret
          key :in, :formData
          key :description, "Application Secret -- See #{AuthenticationApidocs::apps_list_url}"
          key :required, true
          key :type, :string
          key :default, Rails.configuration.swagger_default_client_secret
        end
        parameter do
          key :name, :grant_type
          key :in, :formData
          key :description, "OAuth grant type, valid values: 'password' (for username/password login), 'client_credentials' (for initial client app authentication) or 'assertion' for social media login"
          key :required, true
          key :type, :string
          key :default, 'password'
        end
        parameter do
          key :name, :assertion
          key :in, :formData
          key :description, "External auth provider token (for 'assertion' grant_type). Must be in this format <b>PROVIDER:access_token:access_token_secret</b>. Currently supported providers are FACEBOOK, TWITTER and GOOGLE. access_token_secret is only required for TWITTER"
          key :type, :string
          key :default, 'FACEBOOK:users_access_token'
        end
        parameter do
          key :name, :username
          key :in, :formData
          key :description, "Username of user being authenticated (for 'password' grant_type)"
          key :type, :string
        end
        parameter do
          key :name, :password
          key :in, :formData
          key :description, "Password of user being authenticated (for 'password' grant_type)"
          key :type, :string
        end
        parameter do
          key :name, :refresh_token
          key :in, :formData
          key :description, "Refresh token (for 'refresh_token' grant_type only)"
          key :type, :string
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
            key :'$ref', :ErrorModel
          end
        end
      end
    end

    # -----------------------------------------
    # SCHEMAS
    # -----------------------------------------
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