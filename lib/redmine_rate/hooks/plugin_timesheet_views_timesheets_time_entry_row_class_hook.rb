module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetsTimeEntryRowClassHook < Redmine::Hook::ViewListener
      include TimesheetHookHelper

      def plugin_timesheet_views_timesheets_time_entry_row_class(context={})
        time_entry = context[:time_entry]
        return "" unless time_entry

        cost = cost_item(time_entry)
        return "" unless cost # Permissions
        
        if cost && cost <= 0
          return "missing-rate"
        else
          return ""
        end
      end
    end
  end
end
