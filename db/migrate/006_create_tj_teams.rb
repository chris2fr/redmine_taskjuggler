# encoding: utf-8
##
# A new object for TJ-Teams. Not yet nested.
class CreateTjTeams < ActiveRecord::Migration
  def change
    create_table :tj_teams do |t|
      t.string :name
    end
    add_index(:tj_teams, :name, {unique: true})
  end
end
