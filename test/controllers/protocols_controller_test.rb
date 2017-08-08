require 'test_helper'

class ProtocolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @protocol = protocols(:one)
  end

  test "should get index" do
    get protocols_url
    assert_response :success
  end

  test "should get new" do
    get new_protocol_url
    assert_response :success
  end

  test "should create protocol" do
    assert_difference('Protocol.count') do
      post protocols_url, params: { protocol: { DefinitionData: @protocol.DefinitionData, Name: @protocol.Name, Type: @protocol.Type, Version: @protocol.Version } }
    end

    assert_redirected_to protocol_url(Protocol.last)
  end

  test "should show protocol" do
    get protocol_url(@protocol)
    assert_response :success
  end

  test "should get edit" do
    get edit_protocol_url(@protocol)
    assert_response :success
  end

  test "should update protocol" do
    patch protocol_url(@protocol), params: { protocol: { DefinitionData: @protocol.DefinitionData, Name: @protocol.Name, Type: @protocol.Type, Version: @protocol.Version } }
    assert_redirected_to protocol_url(@protocol)
  end

  test "should destroy protocol" do
    assert_difference('Protocol.count', -1) do
      delete protocol_url(@protocol)
    end

    assert_redirected_to protocols_url
  end
end
