module RateTimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :rate

      before_save :recalculate_cost
      
    end

  end
  
  module ClassMethods
    # Updated the cached cost of all TimeEntries for user and project
    def update_cost_cache(user, project=nil)
      #c = ARCondition.new
      #c << ["#{TimeEntry.table_name}.user_id = ?", user]
      #c << ["#{TimeEntry.table_name}.project_id = ?", project] if project
      scope = self
      scope = scope.scoped(:conditions => ["#{TimeEntry.table_name}.user_id = ?", user])
      scope = scope.scoped(:conditions => ["#{TimeEntry.table_name}.project_id = ?", project]) if project

      scope.all.each do |time_entry|
        time_entry.save_cached_cost
      end
    end
  end
  
  module InstanceMethods
    # Returns the current cost of the TimeEntry based on it's rate and hours
    #
    # Is a read-through cache method
    def cost(options={})
      store_to_db = options[:store] || false
      
      unless read_attribute(:cost)
        if self.rate.nil?
          amount = Rate.amount_for(self.user, self.project, self.spent_on.to_s)
        else
          amount = rate.amount
        end

        if amount.nil?
          write_attribute(:cost, 0.0)
        else
          if store_to_db
            # Write the cost to the database for caching
            update_attribute(:cost, amount.to_f * hours.to_f)
          else
            # Cache to object only
            write_attribute(:cost, amount.to_f * hours.to_f)
          end
        end
      end

      read_attribute(:cost)
    end

    def clear_cost_cache
      write_attribute(:cost, nil)
    end
    
    def save_cached_cost
      clear_cost_cache
      update_attribute(:cost, cost)
    end

    def recalculate_cost
      clear_cost_cache
      cost(:store => false)
      true # for callback
    end
    
  end
end


