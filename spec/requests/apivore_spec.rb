require 'spec_helper'

RSpec.describe 'the API', type: :apivore, order: :defined do
  let(:json_headers) { { "_headers" => {'accept' => 'application/json'} } }
  subject { Apivore::SwaggerChecker.instance_for('/apidocs/v1/swagger.json') }

  context 'has valid paths' do

    # tests go here
    it { is_expected.to validate( :get, '/v1/studies', 200, json_headers ) }

    specify do
      expect(subject).to validate(
        :post '/v1/studies', 200, json_headers.merge({"_data" => {'title' => 'test test'}) }
      )
    end
  end

  context 'and' do
    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
  end
end

