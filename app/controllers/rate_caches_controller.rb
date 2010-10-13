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

  def update
    if params[:cache].present?
      if params[:cache].match(/missing/)
        Rate.update_all_time_entries_with_missing_cost(:force => true)
        flash[:notice] = l(:text_caches_loaded_successfully)
      elsif params[:cache].match(/reload/)
        Rate.update_all_time_entries_to_refresh_cache(:force => true)
        flash[:notice] = l(:text_caches_loaded_successfully)
      end
    end
    redirect_to :action => 'index'
  end
end
