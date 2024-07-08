# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

module Api
  module V1
    class TimeSeriesControllerTest < ActionDispatch::IntegrationTest
      test 'not logged in' do
        get client_app_url, as: :html
        assert_response :success, 'Request failed'
      end

      test 'wrong format' do
        get client_app_url, as: :xml, headers: { 'Accept' => 'application/xml' }
        assert_response :missing, 'Request succeeded'
      end
    end
  end
end
