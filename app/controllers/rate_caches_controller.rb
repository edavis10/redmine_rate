class RateCachesController < ApplicationController
  unloadable

  layout 'admin'
  
  before_filter :require_admin

  def index
    @last_caching_run = if Setting.plugin_redmine_rate['last_caching_run'].present? && Setting.plugin_redmine_rate['last_caching_run'].to_date
                          format_time(Setting.plugin_redmine_rate['last_caching_run'])
                        else
                          l(:text_no_cache_run)
                        end

    @last_cache_clearing_run = if Setting.plugin_redmine_rate['last_cache_clearing_run'].present? && Setting.plugin_redmine_rate['last_cache_clearing_run'].to_date
                          format_time(Setting.plugin_redmine_rate['last_cache_clearing_run'])
                        else
                          l(:text_no_cache_run)
                        end

  end
end
