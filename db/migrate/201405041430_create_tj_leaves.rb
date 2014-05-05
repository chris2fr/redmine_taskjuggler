# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjLeaves < ActiveRecord::Migration
  def change
    create_table :tj_leaves do |t|
      t.string :code
      t.string :name
      t.string :date_or_interval
      t.int :tj_project_id
      t.timestamps
    end
    add_index(:tj_leaves, :tj_project_id)
  end
end