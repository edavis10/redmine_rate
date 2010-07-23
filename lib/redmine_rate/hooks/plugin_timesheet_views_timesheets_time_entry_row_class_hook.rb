module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetsTimeEntryRowClassHook < Redmine::Hook::ViewListener
      def plugin_timesheet_views_timesheets_time_entry_row_class(context={})
        return ''
      end
    end
  end
end
