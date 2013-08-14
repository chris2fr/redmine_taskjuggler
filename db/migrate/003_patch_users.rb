class PatchUsers < ActiveRecord::Migration
  def change
    add_column :users, :tj_activated, :boolean
    add_column :users, :tj_parent,  :string
    add_column :users, :tj_late, :float
    add_column :users, :tj_vacations, :text
    add_column :users, :tj_limits, :string
  end
end
