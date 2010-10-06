module RateTimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :rate
      
    end

  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    # Returns the current cost of the TimeEntry based on it's rate and hours
    def cost
      unless @cost
        if self.rate.nil?
          amount = Rate.amount_for(self.user, self.project, self.spent_on.to_s)
        else
          amount = rate.amount
        end

        if amount.nil?
          @cost = 0.0
        else
          @cost = amount.to_f * hours.to_f
        end
        
        cache_cost
      end

      @cost
    end
    
    def cache_cost
      @cost ||= cost
      update_attribute(:cost, @cost)
    end
  end
end


