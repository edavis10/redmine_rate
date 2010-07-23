module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetTimeEntryHook < Redmine::Hook::ViewListener
      def plugin_timesheet_views_timesheet_time_entry(context={})
        return ''
      end
    end
  end
end
