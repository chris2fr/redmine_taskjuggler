# Users mirror resources in TaskJuggler

class CreateTJUsers < ActiveRecord::Migration
  def self.change
    add_column :users, :tj3_squad, :string
    add_column :projects, :tj3_limits, :string
  end
end
