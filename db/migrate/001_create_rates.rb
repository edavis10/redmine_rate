class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.column :amount, :decimal, :precision => 15, :scale => 2
      t.column :user_id, :integer
      t.column :project_id, :integer
      t.column :date_in_effect, :date
    end
  end

  def self.down
    drop_table :rates
  end
end
