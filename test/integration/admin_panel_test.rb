require 'test_helper'

class AdminPanelTest < ActionController::IntegrationTest
  def setup
    @user = User.generate!(:admin => true, :password => 'rates', :password_confirmation => 'rates')
    
    login_as(@user.login, 'rates')
  end

  context "Rate Caches admin panel" do
    should "be listed in the main Admin section" do
      click_link "Administration"
      assert_response :success

      assert_select "#admin-menu" do
        assert_select "a.rate-caches"
      end
      
    end
    
    should "show the last run timestamp for the last caching run"
    should "show the last run timestamp for the last cache clearing run"
    should "have a button to force a caching run"
    should "have a button to force a cache clearing run"
  end
end
