# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjBookings < ActiveRecord::Migration
  def change
    create_table :tj_bookings do |t|
      t.int :tj_task_id # a leaf task
      t.int :tj_resource_id # a leaf resource
      t.timestamps
    end
    add_index(:tj_bookings, :tj_task_id)
    add_index(:tj_bookings, :tj_resource_id)
    add_column :time_entries, :tj_booking_id, :int
    add_index(:time_entries, :tj_booking_id)
  end
end