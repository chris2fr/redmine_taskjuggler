# encoding: utf-8
##
# I think this is too much and not needed. I compute the start time now.
class PatchTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :tj_start, :string
    #create_table :red_task_time_entries do |t|
    #  t.references :time_entry, index: { name: 'index_time_entry_on_time_entry_id' }
    #  t.boolean :active, default: true
    #  t.datetime :start 
    #end
  end
end
