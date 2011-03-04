= Redmine Rate Plugin

The Rate plugin stores billable rates for Users.  It also provides an API that can be used to find the rate for a Member of a Project at a specific date.

== Features

* Track rates for a user based on
  * Date Rate came into effect and
  * the Project
* Store historic rate amounts
* Lock rates to preserve historic calculations
* Rate.for API for other plugins
* Integration with the Billing plugin
* Integration with the Budget plugin
* Integration with the Contracts plugin

== Getting the plugin

A copy of the plugin can be downloaded from {Little Stream Software}[https://projects.littlestreamsoftware.com/projects/redmine-rate/files] or from {GitHub}[http://github.com/edavis10/redmine_rate/tree/master]


== Installation and Setup

There are two sets of steps to install this plugin.  The first one should be done if you have used version 0.1.0 of the Budget Plugin or 0.2.0 of the Billing Plugin.  This is because the rate data needs to be migrated out of the Budget plugin and into this plugin.

=== Option #1: If you have data from a previous version of Budget or Billing

These installation instructions are very specific because the Rate plugin adjusts data inside the Budget plugin so several data integrity checks are needed.

0. Backup up your data! Backup your data!
1. Install the Lockfile gem
2. Follow the Redmine plugin installation steps a http://www.redmine.org/wiki/redmine/Plugins  Make sure the plugin is installed to +vendor/plugins/redmine_rate+
3. Make sure you are running the 0.1.0 version of the Budget plugin and 0.0.1 version of the Billing plugin
4. Run the pre_install_export to export your current budget and billing data to file +rake rate_plugin:pre_install_export+
5. Run the plugin migrations +rake db:migrate_plugins+ in order to get the new tables for Rates
6. Upgrade the budget plugin to 0.2.0 and the billing plugin to 0.3.0
7. Rerun the plugin migrations +rake db:migrate_plugins+ in order to update to Budget's 0.2.0 schema
8. Run the post_install_check to check your exported data (from #3 above) against the new Rate data. +rake rate_plugin:post_install_check+
9. If the script reports no errors, proceed.  If errors are found, please file a bug report and revert to your backups
10. Restart your Redmine web servers (e.g. mongrel, thin, mod_rails)
11. Setup the "View Rate" permission for any Role that should be allowed to see the user rates in a Project

=== Option #2: If you do not have any data from Budget or Billing

1. Install the Lockfile gem
2. Follow the Redmine plugin installation steps a http://www.redmine.org/wiki/redmine/Plugins  Make sure the plugin is installed to +vendor/plugins/redmine_rate+
3. Run the plugin migrations +rake db:migrate_plugins+ in order to get the new tables for Rates
4. Restart your Redmine web servers (e.g. mongrel, thin, mod_rails)
5. Setup the "View Rate" permission for any Role that should be allowed to see the user rates in a Project

== Usage

=== Enter new rate for a project

There are two ways to set rates for a Member of a Project.

1. Browse to the Project Settings page
2. Select the Members tab
3. Enter the rate for the Member and click the set Rate

Alternatively, Rates can be set in the User Administration panel

1. Browse to the Administration panel
2. Select Users
3. Select the specific user to add a rate for
4. Select the Membership tab and enter a rate for each project
4. Or, select the Rate History and enter a new rate in the form

=== Enter default rate for a user

A default rate is a user's Rate that doesn't correspond to a specific project.  It can be set in the User Administration panel:

1. Browse to the Administration panel
2. Select Users
3. Select the specific user to add a rate for
4. Select the Rate History and enter a new rate in the form, keep the Project field set to Default Rate.

=== Lock a Rate

Currently this feature is only available through the Rate API.  A Rate will become locked once a valid TimeEntry is assigned to the Rate.

=== Caching

The plugin includes some simple caching for time entries cost. Instead of doing a lookup for each time entry, the rate plugin will cache the total cost for each time entry to the database. The caching is done transparently but you can run and purge the caches from the Administration Panel or using the provided rate tasks (rake rate_plugin:update_cost_cache, rake rate_plugin:refresh_cost_cache).

== License

This plugin is licensed under the GNU GPL v2.  See COPYRIGHT.txt and GPL.txt for details.

== Project help

If you need help you can contact the maintainer on the Bug Tracker.  The bug tracker is located at  https://projects.littlestreamsoftware.com

