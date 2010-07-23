module RedmineRate
  module Hooks
    class PluginTimesheetViewTimesheetsReportHeaderTagsHook < Redmine::Hook::ViewListener
      def plugin_timesheet_view_timesheets_report_header_tags(context={})
        return content_tag(:style,
                           'tr.missing-rate td.cost { color: red; }',
                           :type => 'text/css')
      end
    end
  end
end
