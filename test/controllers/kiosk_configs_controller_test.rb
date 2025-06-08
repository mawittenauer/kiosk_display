require "test_helper"

class KioskConfigsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get kiosk_configs_index_url
    assert_response :success
  end

  test "should get create" do
    get kiosk_configs_create_url
    assert_response :success
  end

  test "should get update" do
    get kiosk_configs_update_url
    assert_response :success
  end
end
