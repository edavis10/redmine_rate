require File.dirname(__FILE__) + '/../../test_helper'

class UsersHelperWrapper
  include UsersHelper
end

class RateUsersHelperPatchTest < ActiveSupport::TestCase
  should 'should return 3 tabs' do
    helper = UsersHelperWrapper.new
    assert_equal 3, helper.user_settings_tabs.length
  end
  
  should 'should include a rate tab at the end' do
    helper = UsersHelperWrapper.new
    rate_tab = helper.user_settings_tabs[-1]
    assert_not_nil rate_tab
  end

  context 'rate tab' do
    setup do
      helper = UsersHelperWrapper.new
      @rate_tab = helper.user_settings_tabs[-1]
    end

    should 'should have the name of "rates"' do
      assert_equal 'rates', @rate_tab[:name]
    end

    should 'should use the rates partial' do
      assert_equal 'users/rates', @rate_tab[:partial]
    end

    should 'should use the i18n rates label' do
      assert_equal :rate_label_rate_history, @rate_tab[:label]
    end
  end
end
