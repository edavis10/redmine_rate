require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineRate::Hooks::PluginTimesheetViewsTimesheetsTimeEntryRowClassTest < ActionController::TestCase
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
    call_hook :plugin_timesheet_views_timesheets_time_entry_row_class, args
  end

  context "#plugin_timesheet_views_timesheets_time_entry_row_class" do
    context "for users with view rate permission" do
      setup do
        User.current = User.generate!(:admin => true)
      end

      should "render a missing rate css class if the time entry has no cost" do
        time_entry = TimeEntry.generate!(:hours => 2, :rate => nil)

        assert_equal "missing-rate", hook(:time_entry => time_entry)
      end

      should "render nothing if the time entry has a cost" do
        rate = Rate.generate!(:amount => 100)
        time_entry = TimeEntry.generate!(:hours => 2, :rate => rate)

        assert_equal "", hook(:time_entry => time_entry)
      end
    end

    context "for users without view rate permission" do
      setup do
        User.current = nil
      end

      should "render nothing if the time entry has no cost" do
        time_entry = TimeEntry.generate!(:hours => 2, :rate => nil)

        assert_equal "", hook(:time_entry => time_entry)
      end

      should "render nothing if the time entry has a cost" do
        rate = Rate.generate!(:amount => 100)
        time_entry = TimeEntry.generate!(:hours => 2, :rate => rate)

        assert_equal "", hook(:time_entry => time_entry)
      end
    end    

  end
end
