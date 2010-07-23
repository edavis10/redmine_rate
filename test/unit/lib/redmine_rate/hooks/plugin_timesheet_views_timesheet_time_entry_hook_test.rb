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
    should "return an empty string" do
      @response.body = hook
      assert @response.body.blank?
    end
  end
end
