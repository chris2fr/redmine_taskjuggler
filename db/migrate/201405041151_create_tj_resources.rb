# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjResources < ActiveRecord::Migration
  def change
    create_table :tj_resources do |t|
      t.string :name
      t.string :code
      t.int :tj_resource_id
      t.int :user_id
      t.string :type
      t.timestamps
    end
    add_index(:tj_task, :tj_resource_id)
    add_index(:tj_task, :user_id)
  end
end