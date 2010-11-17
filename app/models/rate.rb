require 'lockfile'

class Rate < ActiveRecord::Base
  unloadable
  class InvalidParameterException < Exception; end
  CACHING_LOCK_FILE_NAME = 'rate_cache'

  belongs_to :project
  belongs_to :user
  has_many :time_entries
  
  validates_presence_of :user_id
  validates_presence_of :date_in_effect
  validates_numericality_of :amount
  
  before_save :unlocked?
  after_save :update_time_entry_cost_cache
  before_destroy :unlocked?
  after_destroy :update_time_entry_cost_cache
  
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

  def update_time_entry_cost_cache
    TimeEntry.update_cost_cache(user, project)
  end
  
  # API to find the Rate for a +user+ on a +project+ at a +date+
  def self.for(user, project = nil, date = Date.today.to_s)
    # Check input since it's a "public" API
    if Object.const_defined? 'Group' # 0.8.x compatibility
      raise Rate::InvalidParameterException.new("user must be a Principal instance") unless user.is_a?(Principal)
    else
      raise Rate::InvalidParameterException.new("user must be a User instance") unless user.is_a?(User)
    end
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

  def self.update_all_time_entries_with_missing_cost(options={})
    with_common_lockfile(options[:force]) do
      TimeEntry.all(:conditions => {:cost => nil}).each do |time_entry|
        begin
          time_entry.save_cached_cost
        rescue Rate::InvalidParameterException => ex
          puts "Error saving #{time_entry.id}: #{ex.message}"
        end
      end
    end
    store_cache_timestamp('last_caching_run', Time.now.utc.to_s)
  end

  def self.update_all_time_entries_to_refresh_cache(options={})
    with_common_lockfile(options[:force]) do
      TimeEntry.find_each do |time_entry| # batch find
        begin
          time_entry.save_cached_cost
        rescue Rate::InvalidParameterException => ex
          puts "Error saving #{time_entry.id}: #{ex.message}"
        end
      end
    end
    store_cache_timestamp('last_cache_clearing_run', Time.now.utc.to_s)
  end
  
  private
  def self.for_user_project_and_date(user, project, date)
    if project.nil?
      return Rate.find(:first,
                       :order => 'date_in_effect DESC',
                       :conditions => [
                                       "user_id IN (?) AND date_in_effect <= ? AND project_id IS NULL",
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

  def self.store_cache_timestamp(cache_name, timestamp)
    Setting.plugin_redmine_rate = Setting.plugin_redmine_rate.merge({cache_name => timestamp})
  end

  def self.with_common_lockfile(force = false, &block)
    # Wait 1 second after stealing a forced lock
    options = {:retries => 0, :suspend => 1}
    options[:max_age] = 1 if force
    
    Lockfile(lock_file, options) do
      block.call
    end
  end

  if Rails.env.test?
    public
    generator_for :date_in_effect => Date.today
  end

  def self.lock_file
    Rails.root + 'tmp' + Rate::CACHING_LOCK_FILE_NAME
  end
end
