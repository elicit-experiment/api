require 'test_helper'
require "minitest/unit"
require "mocha/mini_test"
require 'minitest/mock'

class StubToken
  def acceptable?(*scopes)
    puts "testing stub"
    true
  end
end

class StudyDefinitionControllerTest < ActionDispatch::IntegrationTest
#  include Devise::TestHelpers 

  setup do
    @study_definition = study_definitions(:one)
    @user = users(:one)
    @dk_app = oauth_applications(:test_app)
    @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
    @token.save!
# unecessary
#    StudyDefinitionsController.any_instance.stubs(:doorkeeper_token).returns(@token)
    @headers = { :Authorization => "Bearer #{@token.token}"}
  end


  test "should get index" do
    get study_definitions_url, as: :json, :headers => @headers
    assert_response :success
  end

  test "should get new" do
    get new_study_definition_url, as: :json, :headers => @headers
    assert_response :success
  end

  test "should create study_definition" do
    assert_difference('StudyDefinition.count') do
      post study_definitions_url, params: { title: "test post", principal_investigator_user_id: 0 }, :as => :json, :headers => @headers
    end

    assert_response :success
  end

  test "should show study_definition" do
    get study_definition_url(@study_definition), as: :json, :headers => @headers
    assert_response :success
  end

  test "should get edit" do
    get edit_study_definition_url(@study_definition), as: :json, :headers => @headers
    assert_response :success
  end

  test "should update study_definition" do
    patch study_definition_url(@study_definition), params: { title: "new" }, :as => :json, :headers => @headers
    assert_response :success
  end

  test "should destroy study_definition" do
    assert_difference('StudyDefinition.count', -1) do
      delete study_definition_url(@study_definition), :as => :json, :headers => @headers
    end

    assert_response :success
  end
end
