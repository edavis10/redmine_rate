require File.dirname(__FILE__) + '/../spec_helper'

class UsersHelperWrapper
  include UsersHelper
end

describe UsersHelper, 'user_settings' do
  it 'should return 3 tabs' do
    helper = UsersHelperWrapper.new
    helper.user_settings_tabs.should have(3).things
    
  end
  
  it 'should include a rate tab at the end' do
    helper = UsersHelperWrapper.new
    rate_tab = helper.user_settings_tabs[-1]
    rate_tab.should_not be_nil
  end

  describe 'rate tab' do
    before(:each) do
      helper = UsersHelperWrapper.new
      @rate_tab = helper.user_settings_tabs[-1]
    end

    it 'should have the name of "rates"' do
      @rate_tab[:name].should eql('rates')
    end

    it 'should use the rates partial' do
      @rate_tab[:partial].should eql('users/rates')
    end

    it 'should use the i18n rates label' do
      @rate_tab[:label].should eql(:rate_label_rates)
    end
  end
end
