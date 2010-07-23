module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetGroupHeaderHook < Redmine::Hook::ViewListener
      def plugin_timesheet_views_timesheet_group_header(context={})
        return content_tag(:th, l(:rate_cost), :width => '8%')
      end
    end
  end
end
