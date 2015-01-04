# encoding: utf-8
##
# Extra fields to have resources from users
class PatchUsers < ActiveRecord::Migration
  def change
    add_column :users, :tj_activated, :boolean, :default => true
    add_column :users, :tj_parent,  :string
    add_column :users, :tj_rate, :float
    add_column :users, :tj_vacations, :text
    add_column :users, :tj_limits, :string
  end
end
