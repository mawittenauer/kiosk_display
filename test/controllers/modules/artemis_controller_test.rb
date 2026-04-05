require "test_helper"

class Modules::ArtemisControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get modules_artemis_index_url
    assert_response :success
  end

  test "returns mission data as json" do
    get modules_artemis_index_url
    data = JSON.parse(response.body)
    assert_equal "Artemis II", data["mission_name"]
    assert data["crew"].is_a?(Array)
    assert_equal 4, data["crew"].length
    assert data["milestones"].is_a?(Array)
    assert data["launch_time"].present?
    assert data["status"].present?
    assert data["phase_key"].present?
    assert data.key?("progress_pct")
    assert data.key?("elapsed_hours")
    assert data["phases"].is_a?(Array)
  end
end
