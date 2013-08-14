class PatchIssues < ActiveRecord::Migration
  def change
    add_column :issues, :tj_activated, :boolean
    add_column :issues, :tj_depends, :string
    add_column :issues, :tj_preceeds, :string
    add_column :issues, :tj_parent, :string
    add_column :issues, :tj_scheduled, :boolean
    add_column :issues, :tj_allocates, :string # Users
    add_column :issues, :tj_limits, :string
  end
end
