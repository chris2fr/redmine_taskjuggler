# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjAllocations < ActiveRecord::Migration
  def change
    create_table :tj_allocations do |t|
      t.int :tj_resource
      t.int :tj_task
      t.string :value
      t.timestamps
    end
    add_index(:tj_allocations, :tj_resource)
    add_index(:tj_allocations, :tj_task)
  end
end