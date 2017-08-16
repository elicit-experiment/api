class Apidocs::V1::StudiesApidocs
  include Swagger::Blocks

  swagger_path '/v1/studies' do
    operation :get do
      key :summary, 'All Studies'
      key :description, 'Returns all studies from the system that the user has access to'
      key :operationId, 'findStudies'
      key :produces, [
        'application/json',
        'text/html',
      ]
      key :tags, [
        'study'
      ]
      response 200 do
        key :description, 'study response'
        schema do
          key :type, :array
          items do
            key :'$ref', :Study
          end
        end
      end
      #      response :default do
      #        key :description, 'unexpected error'
      #        schema do
      #          key :'$ref', :ErrorModel
      #        end
      #      end
    end

    operation :post do
      key :description, 'Creates a new study'
      key :operationId, 'addStudy'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'study'
      ]
      parameter do
        key :name, :study
        key :in, :body
        key :description, 'Study to add to the store'
        key :required, true
        schema do
          key :'$ref', :StudyInput
        end
      end
      response 200 do
        key :description, 'study response'
        schema do
          key :'$ref', :Study
        end
      end
      response :default do
        key :description, 'unexpected error'
        schema do
          key :'$ref', :ErrorModel
        end
      end
    end


  end



end
