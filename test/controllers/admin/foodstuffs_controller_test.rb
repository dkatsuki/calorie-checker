require "test_helper"

class Admin::FoodstuffsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_foodstuffs_index_url
    assert_response :success
  end
end
