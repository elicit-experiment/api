require 'test_helper'

class StudyProtocolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @study_protocol = study_protocols(:one)
  end

  test "should get index" do
    get study_protocols_url
    assert_response :success
  end

  test "should get new" do
    get new_study_protocol_url
    assert_response :success
  end

  test "should create study_protocol" do
    assert_difference('StudyProtocol.count') do
      post study_protocols_url, params: { study_protocol: { belongs_to: @study_protocol.belongs_to, belongs_to: @study_protocol.belongs_to } }
    end

    assert_redirected_to study_protocol_url(StudyProtocol.last)
  end

  test "should show study_protocol" do
    get study_protocol_url(@study_protocol)
    assert_response :success
  end

  test "should get edit" do
    get edit_study_protocol_url(@study_protocol)
    assert_response :success
  end

  test "should update study_protocol" do
    patch study_protocol_url(@study_protocol), params: { study_protocol: { belongs_to: @study_protocol.belongs_to, belongs_to: @study_protocol.belongs_to } }
    assert_redirected_to study_protocol_url(@study_protocol)
  end

  test "should destroy study_protocol" do
    assert_difference('StudyProtocol.count', -1) do
      delete study_protocol_url(@study_protocol)
    end

    assert_redirected_to study_protocols_url
  end
end
