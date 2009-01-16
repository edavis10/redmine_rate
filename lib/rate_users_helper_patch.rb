require_dependency 'users_helper'

module RateUsersHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :user_settings_tabs, :rate_tab
    end
  end
  
  module InstanceMethods
    # Adds a rates tab to the user administration page
    def user_settings_tabs_with_rate_tab
      tabs = user_settings_tabs_without_rate_tab
      tabs << { :name => 'rates', :partial => 'users/rates', :label => :rate_label_rates}
      return tabs
    end
    
  end
end

UsersHelper.send(:include, RateUsersHelperPatch)

