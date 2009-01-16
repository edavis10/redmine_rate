class Rate < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :time_entries
  
  validates_presence_of :user_id
  validates_presence_of :date_in_effect
end
