module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetTimeEntryHook < Redmine::Hook::ViewListener
      include TimesheetHookHelper
      
      def plugin_timesheet_views_timesheet_time_entry(context={})
        cost = cost_item(context[:time_entry])
        if cost
          td_cell(number_to_currency(cost))
        else
          td_cell('&nbsp;')
        end

      end

    end
  end
end
