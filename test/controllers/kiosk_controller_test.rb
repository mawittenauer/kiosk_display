require "test_helper"

class KioskControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get kiosk_index_url
    assert_response :success
  end
end
