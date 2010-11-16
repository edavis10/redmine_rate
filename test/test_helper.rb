# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

module IntegrationTestHelper
  def login_as(user="existing", password="existing")
    visit "/login"
    fill_in 'Login', :with => user
    fill_in 'Password', :with => password
    click_button 'login'
    assert_response :success
    assert User.current.logged?
  end

  def logout
    visit '/logout'
    assert_response :success
    assert !User.current.logged?
  end
  
  def assert_forbidden
    assert_response :forbidden
    assert_template 'common/error'
  end

  def assert_requires_login
    assert_response :success
    assert_template 'account/login'
  end
  
end

class ActionController::IntegrationTest
  include IntegrationTestHelper
end
