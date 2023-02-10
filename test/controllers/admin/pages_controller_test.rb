require "test_helper"

class Admin::PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get admin_pages_top_url
    assert_response :success
  end
end
