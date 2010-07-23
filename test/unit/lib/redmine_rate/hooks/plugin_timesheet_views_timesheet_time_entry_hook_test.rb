require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineRate::Hooks::PluginTimesheetViewsTimesheetTimeEntryTest < ActionController::TestCase
  include Redmine::Hook::Helper

  def controller
    @controller ||= ApplicationController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  
  def hook(args={})
    call_hook :plugin_timesheet_views_timesheet_time_entry, args
  end

  context "#plugin_timesheet_views_timesheet_time_entry" do
    context "for users with view rate permission" do
      should "render a cost cell showing the cost for the time entry" do
        User.current = User.generate!(:admin => true)
        rate = Rate.generate!(:amount => 100)
        time_entry = TimeEntry.generate!(:hours => 2, :rate => rate)
        
        @response.body = hook(:time_entry => time_entry)

        assert_select 'td', :text => "$200.00"
        
      end
    end

    context "for users without view rate permission" do
      should "render an empty cost cell" do
        User.current = nil
        rate = Rate.generate!(:amount => 100)
        time_entry = TimeEntry.generate!(:hours => 2, :rate => rate)
        
        @response.body = hook(:time_entry => time_entry)

        assert_select 'td', :text => '&nbsp;'
        
      end
    end    
  end
end
