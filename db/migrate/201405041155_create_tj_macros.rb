# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjMacros < ActiveRecord::Migration
  def change
    create_table :tj_macros do |t|
      t.string :value
      t.int :tj_project_id
      t.timestamps
    end
    add_index(:tj_macros, :tj_project_id)
  end
end