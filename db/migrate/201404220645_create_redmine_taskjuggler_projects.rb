# encoding: utf-8
##
# This is for I guess sheduling executions. Rails likes objects to 
# be also in the database.
class CreateRedmineTaskjugglerProjects < ActiveRecord::Migration
  def change
    create_table :redmine_taskjuggler_projects do |t|
      t.integer :project_id
    end
    add_index(:redmine_taskjuggler_projects, :project_id)
  end
end