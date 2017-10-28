class Apidocs::V1::ParticipantApidocs
  include Swagger::Blocks

  swagger_path '/participant/eligeable_protocols' do
    operation :get do
      key :description, 'Returns a list of protocols for which the current user is eligeable'
      key :summary, 'Returns a list of ProtocolUsers'
      key :operationId, 'findEligeableProtocols'
      key :tags, [
        'Users', 'Study Participation'
      ]
      parameter do
        key :name, :authorization
        key :in, :header
        key :description, "Authenticated user's access token"
        key :required, true
        key :type, :string
        key :default, 'Bearer PASTE_ACCESS_TOKEN_HERE'
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



end
