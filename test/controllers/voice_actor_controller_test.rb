require "test_helper"

class VoiceActorControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get voice_actor_new_url
    assert_response :success
  end

  test "should get create" do
    get voice_actor_create_url
    assert_response :success
  end

  test "should get show" do
    get voice_actor_show_url
    assert_response :success
  end

  test "should get edit" do
    get voice_actor_edit_url
    assert_response :success
  end

  test "should get update" do
    get voice_actor_update_url
    assert_response :success
  end

  test "should get destroy" do
    get voice_actor_destroy_url
    assert_response :success
  end
end
