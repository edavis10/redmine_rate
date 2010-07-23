module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetTimeEntrySumHook < Redmine::Hook::ViewListener
      def plugin_timesheet_views_timesheet_time_entry_sum(context={})
        return ''
      end
    end
  end
end
