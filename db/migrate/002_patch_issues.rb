# encoding: utf-8
##
# Extra fields to have tasks from Issues
class PatchIssues < ActiveRecord::Migration
  def change
    add_column :issues, :tj_activated, :boolean, :default => true
    add_column :issues, :tj_depends, :string
    add_column :issues, :tj_preceeds, :string
    add_column :issues, :tj_parent, :string
    add_column :issues, :tj_scheduled, :boolean, :default => false
    add_column :issues, :tj_allocates, :string # Users
    add_column :issues, :tj_limits, :string	# add limits for issue (task)
    add_column :issues, :tj_priority, :string, :default => '500' # add priority for issue (task); by default priority = '500' - normal priority of the task
    add_column :issues, :tj_efficiency, :string
  end
end
