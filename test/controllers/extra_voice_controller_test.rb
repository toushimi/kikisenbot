require "test_helper"

class ExtraVoiceControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get extra_voice_index_url
    assert_response :success
  end

  test "should get show" do
    get extra_voice_show_url
    assert_response :success
  end

  test "should get new" do
    get extra_voice_new_url
    assert_response :success
  end

  test "should get create" do
    get extra_voice_create_url
    assert_response :success
  end

  test "should get edit" do
    get extra_voice_edit_url
    assert_response :success
  end

  test "should get update" do
    get extra_voice_update_url
    assert_response :success
  end

  test "should get destroy" do
    get extra_voice_destroy_url
    assert_response :success
  end
end
