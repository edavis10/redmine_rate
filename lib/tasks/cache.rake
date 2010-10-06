require 'lockfile'

namespace :rate_plugin do
  namespace :cache do
    desc "Update Time Entry cost caches"
    task :update_cost_cache => :environment do
      Lockfile('update_cost_cache', :retries => 0) do
        TimeEntry.all(:conditions => {:cost => nil}).each do |time_entry|
          begin
            time_entry.save_cached_cost
          rescue Rate::InvalidParameterException => ex
            puts "Error saving #{time_entry.id}: #{ex.message}"
          end
          
        end
        
      end
    end
  end
end
