require 'test_helper'

class AdminPanelTest < ActionController::IntegrationTest
  include Redmine::I18n
  
  def setup
    @last_caching_run = 4.days.ago.to_s
    @last_cache_clearing_run = 7.days.ago.to_s
    
    Setting.plugin_redmine_rate = {
      'last_caching_run' => @last_caching_run,
      'last_cache_clearing_run' => @last_cache_clearing_run
    }
    
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
    
    should "show the last run timestamp for the last caching run" do
      click_link "Administration"
      click_link "Rate Caches"
      
      assert_select '#caching-run' do
        assert_select 'p', :text => /#{format_time(@last_caching_run)}/
      end
      
    end

    should "show the last run timestamp for the last cache clearing run" do
      click_link "Administration"
      click_link "Rate Caches"
      
      assert_select '#cache-clearing-run' do
        assert_select 'p', :text => /#{format_time(@last_cache_clearing_run)}/
      end
      
    end
      
    should "have a button to force a caching run" do
      click_link "Administration"
      click_link "Rate Caches"
      click_button "Load Missing Caches"

      assert_response :success

      appx_clear_time = Date.today.strftime("%m/%d/%Y")
      
      assert_select '#caching-run' do
        assert_select 'p', :text => /#{appx_clear_time}/
      end

    end

    should "have a button to force a cache clearing run" do
      click_link "Administration"
      click_link "Rate Caches"
      click_button "Clear and Load All Caches"

      assert_response :success

      appx_clear_time = Date.today.strftime("%m/%d/%Y")
      
      assert_select '#cache-clearing-run' do
        assert_select 'p', :text => /#{appx_clear_time}/
      end

    end
  end
end
