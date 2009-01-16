class AddIndexesToRates < ActiveRecord::Migration
  def self.up
    add_index :rates, :user_id
    add_index :rates, :project_id
    add_index :rates, :date_in_effect
  end

  def self.down
    remove_index :rates, :user_id
    remove_index :rates, :project_id
    remove_index :rates, :date_in_effect
  end
end
