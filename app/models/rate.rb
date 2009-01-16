class Rate < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :time_entries
  
  validates_presence_of :user_id
  validates_presence_of :date_in_effect
  
  named_scope :history_for_user, lambda { |user|
    {
      :conditions => { :user_id => user.id },
      :order => 'date_in_effect DESC'
    }
  }

  def locked?
    return self.time_entries.length > 0
  end
end
