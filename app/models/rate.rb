class Rate < ActiveRecord::Base
  class InvalidParameterException < Exception; end

  belongs_to :project
  belongs_to :user
  has_many :time_entries
  
  validates_presence_of :user_id
  validates_presence_of :date_in_effect
  
  before_save :unlocked?
  before_destroy :unlocked?
  
  named_scope :history_for_user, lambda { |user, order|
    {
      :conditions => { :user_id => user.id },
      :order => order,
      :include => :project
    }
  }
  
  def locked?
    return self.time_entries.length > 0
  end
  
  def unlocked?
    return !self.locked?
  end
  
  def default?
    return self.project.nil?
  end
  
  def specific?
    return !self.default?
  end
  
  # API to find the Rate for a +user+ on a +project+ at a +date+
  def self.for(user, project = nil, date = Date.today.to_s)
    # Check input since it's a "public" API
    raise Rate::InvalidParameterException.new("user must be a User instance") unless user.is_a?(User)
    raise Rate::InvalidParameterException.new("project must be a Project instance") unless project.nil? || project.is_a?(Project)
    Rate.check_date_string(date)
      
    rate = self.for_user_project_and_date(user, project, date)
    # Check for a default (non-project) rate
    rate = self.default_for_user_and_date(user, date) if rate.nil? && project
    rate
  end
  
  # API to find the amount for a +user+ on a +project+ at a +date+
  def self.amount_for(user, project = nil, date = Date.today.to_s)
    rate = self.for(user, project, date)

    return nil if rate.nil?
    return rate.amount
  end
  
  private
  def self.for_user_project_and_date(user, project, date)
    if project.nil?
      return Rate.find(:first,
                       :order => 'date_in_effect DESC',
                       :conditions => [
                                       "user_id IN (?) AND date_in_effect <= ?",
                                       user.id,
                                       date
                                      ])
    
    else
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
  
  def self.default_for_user_and_date(user, date)
    self.for_user_project_and_date(user, nil, date)
  end

  # Checks a date string to make sure it is in format of +YYYY-MM-DD+, throwing
  # a Rate::InvalidParameterException otherwise
  def self.check_date_string(date)
    raise Rate::InvalidParameterException.new("date must be a valid Date string (e.g. YYYY-MM-DD)") unless date.is_a?(String)
    
    begin
      Date.parse(date)
    rescue ArgumentError
      raise Rate::InvalidParameterException.new("date must be a valid Date string (e.g. YYYY-MM-DD)")
    end
  end
end
