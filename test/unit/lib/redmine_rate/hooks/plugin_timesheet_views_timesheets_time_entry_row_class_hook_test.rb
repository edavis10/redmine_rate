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
    should "return an empty string" do
      @response.body = hook
      assert @response.body.blank?
    end
  end
end
