class Rate < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :time_entries
  
  validates_presence_of :user_id
  validates_presence_of :date_in_effect
  
  before_save :unlocked?
  before_destroy :unlocked?
  
  named_scope :history_for_user, lambda { |user|
    {
      :conditions => { :user_id => user.id },
      :order => 'date_in_effect DESC'
    }
  }

  def locked?
    return self.time_entries.length > 0
  end
  
  def unlocked?
    return !self.locked?
  end
  
  # API to find the Rate for a +user+ on a +project+ at a +date+
  def self.for(user, project = nil, date = Date.today.to_s)
    rate = self.for_user_project_and_date(user, project, date)
    
    return nil if rate.nil?
    return rate.amount
  end
  
  private
  def self.for_user_project_and_date(user, project, date)
    return Rate.find(:first,
                     :order => 'date_in_effect DESC',
                     :conditions => [
                                     "user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                     user.id,
                                     project.id,
                                     date
                                    ])
                     
  end
end
