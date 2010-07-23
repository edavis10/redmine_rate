require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineRate::Hooks::PluginTimesheetViewsTimesheetTimeEntrySumTest < ActionController::TestCase
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
    call_hook :plugin_timesheet_views_timesheet_time_entry_sum, args
  end

  context "#plugin_timesheet_views_timesheet_time_entry_sum" do
    context "for users with view rate permission" do
      should "render a cost cell showing the total cost for the time entries" do
        User.current = User.generate!(:admin => true)
        rate = Rate.generate!(:amount => 100)
        time_entry1 = TimeEntry.generate!(:hours => 2, :rate => rate)
        time_entry2 = TimeEntry.generate!(:hours => 10, :rate => rate)
        
        @response.body = hook(:time_entries => [time_entry1, time_entry2])

        assert_select 'td', :text => "$1,200.00"
        
      end
    end

    context "for users without view rate permission" do
      should "render an empty cost cell" do
        User.current = nil
        rate = Rate.generate!(:amount => 100)
        time_entry = TimeEntry.generate!(:hours => 2, :rate => rate)
        
        @response.body = hook(:time_entries => [time_entry])

        assert_select 'td', :text => '$0.00'
        
      end
    end    
  end
end
