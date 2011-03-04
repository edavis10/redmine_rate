require 'redmine'

# Patches to the Redmine core
require 'dispatcher'

Dispatcher.to_prepare :redmine_rate do
  gem 'lockfile'

  require_dependency 'sort_helper'
  SortHelper.send(:include, RateSortHelperPatch)

  require_dependency 'time_entry'
  TimeEntry.send(:include, RateTimeEntryPatch)

  require_dependency 'users_helper'
  UsersHelper.send(:include, RateUsersHelperPatch) unless UsersHelper.included_modules.include?(RateUsersHelperPatch)
end

# Hooks
require 'rate_project_hook'
require 'rate_memberships_hook'

Redmine::Plugin.register :redmine_rate do
  name 'Rate'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-rate'
  author_url 'http://www.littlestreamsoftware.com'
  description "The Rate plugin provides an API that can be used to find the rate for a Member of a Project at a specific date.  It also stores historical rate data so calculations will remain correct in the future."
  version '0.2.0'

  requires_redmine :version_or_higher => '1.0.0'

  # These settings are set automatically when caching
  settings(:default => {
             'last_caching_run' => nil
           })

  permission :view_rate, { }

  menu :admin_menu, :rate_caches, { :controller => 'rate_caches', :action => 'index'}, :caption => :text_rate_caches_panel
end

require 'redmine_rate/hooks/timesheet_hook_helper'
require 'redmine_rate/hooks/plugin_timesheet_views_timesheets_time_entry_row_class_hook'
require 'redmine_rate/hooks/plugin_timesheet_views_timesheet_group_header_hook'
require 'redmine_rate/hooks/plugin_timesheet_views_timesheet_time_entry_hook'
require 'redmine_rate/hooks/plugin_timesheet_views_timesheet_time_entry_sum_hook'
require 'redmine_rate/hooks/plugin_timesheet_view_timesheets_report_header_tags_hook'
require 'redmine_rate/hooks/view_layouts_base_html_head_hook'
