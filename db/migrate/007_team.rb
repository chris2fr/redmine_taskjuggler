class Team < ActiveRecord::Migration
  def change
    add_column :users, :tj_team_id, :integer
    add_index :users, :tj_team_id
  end
end
