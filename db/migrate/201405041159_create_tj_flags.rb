# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjFlags < ActiveRecord::Migration
  def change
    create_table :tj_flags do |t|
      t.string :code
      t.int :tj_project_id
      t.timestamps
    end
    add_index(:tj_projects, :tj_project_id)
  end
end