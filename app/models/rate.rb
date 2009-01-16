class Rate < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :time_entries
end
