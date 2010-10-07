namespace :rate_plugin do
  namespace :cache do
    desc "Update Time Entry cost caches for Time Entries without a cost"
    task :update_cost_cache => :environment do
      Rate.update_all_time_entries_with_missing_cost
    end

    desc "Clear and update all Time Entry cost caches"
    task :refresh_cost_cache => :environment do
      Rate.update_all_time_entries_to_refresh_cache
    end
  end
end
