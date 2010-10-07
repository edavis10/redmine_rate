namespace :rate_plugin do
  namespace :cache do
    desc "Update Time Entry cost caches"
    task :update_cost_cache => :environment do
      Rate.update_all_time_entries_with_missing_cost
    end
  end
end
