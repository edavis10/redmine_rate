module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetGroupHeaderHook < Redmine::Hook::ViewListener
      def plugin_timesheet_views_timesheet_group_header(context={})
        return ''
      end
    end
  end
end
