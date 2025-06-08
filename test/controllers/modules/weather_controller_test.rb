require "test_helper"

class Modules::WeatherControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get modules_weather_index_url
    assert_response :success
  end

  test "should get current" do
    get modules_weather_current_url
    assert_response :success
  end
end
