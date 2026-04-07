# frozen_string_literal: true

require "test_helper"

class Modules::IframeControllerTest < ActionDispatch::IntegrationTest
  test "should get index with url param" do
    get modules_iframe_index_url, params: { url: "https://example.com" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "https://example.com", json["url"]
  end

  test "should get index without url param" do
    get modules_iframe_index_url
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "about:blank", json["url"]
  end

  test "should reject non-http urls" do
    get modules_iframe_index_url, params: { url: "ftp://evil.com/payload" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "about:blank", json["url"]
  end
end
