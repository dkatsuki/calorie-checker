require "test_helper"

class FoodstuffsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get foodstuffs_index_url
    assert_response :success
  end
end
