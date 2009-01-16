class AddRateIdToTimeEntries < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :rate_id, :integer
    add_index :time_entries, :rate_id
  end

  def self.down
    remove_index :time_entries, :rate_id
    remove_column :time_entries, :rate_id
  end
end
