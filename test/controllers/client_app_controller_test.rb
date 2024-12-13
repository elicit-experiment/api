# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

class ClientAppControllerTest < ActionDispatch::IntegrationTest
  test 'not logged in' do
    get client_app_url, as: :html, headers: { 'Accept' => 'text/html' }
    assert_response :success
  end

  test 'wrong format' do
    assert_raises ActionController::RoutingError do
      get client_app_url, as: :json, headers: { 'Accept' => 'application/json' }
    end
  end
end