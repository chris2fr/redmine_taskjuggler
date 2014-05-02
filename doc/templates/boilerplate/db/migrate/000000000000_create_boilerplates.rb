# encoding: utf-8
# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/boilerplates_controller.rb
##
# This is for I guess sheduling executions. Rails likes objects to 
# be also in the database.
class CreateBoilerplates < ActiveRecord::Migration
  def change
    create_table :boilerplates do |t|
      # t.integer :project_id
    end
    # add_index(:redmine_taskjuggler_projects, :project_id)
  end
end