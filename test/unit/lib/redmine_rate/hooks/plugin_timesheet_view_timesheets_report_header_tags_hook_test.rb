require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineRate::Hooks::PluginTimesheetViewTimesheetsReportHeaderTagsTest < ActionController::TestCase
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
    call_hook :plugin_timesheet_view_timesheets_report_header_tags, args
  end

  context "#plugin_timesheet_view_timesheets_report_header_tags" do
    should "return a css string" do
      @response.body = hook
      assert_select "style", :text => /missing-rate/
    end
  end
end
