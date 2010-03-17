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
      if self.rate.nil?
        amount = Rate.amount_for(self.user, self.project, self.spent_on.to_s)
      else
        amount = rate.amount
      end

      return 0.0 if amount.nil?
      
      return amount.to_f * hours.to_f
    end
  end
end


