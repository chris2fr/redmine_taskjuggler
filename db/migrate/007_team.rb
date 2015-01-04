# encoding: utf-8
##
# Fields for the users to reference the team in Rails 3 notation.
# Rails 4 would use reference instead of these two lines.
class Team < ActiveRecord::Migration
  def change
    add_column :users, :tj_team_id, :integer
    add_index :users, :tj_team_id
  end
end
