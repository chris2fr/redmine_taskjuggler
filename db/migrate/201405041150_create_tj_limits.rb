# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjLimits < ActiveRecord::Migration
  def change
    create_table :tj_limits do |t|
      t.float value
      t.string type # weekly_max etc.
      t.string units # h, d, m, y etc.
      t.date :start
      t.date :end
      t.string :interval
      t.int :tj_task_id # for the task being limited
      t.timestamps
    end
    add_index(:tj_limits, :tj_task_id)
  end
end