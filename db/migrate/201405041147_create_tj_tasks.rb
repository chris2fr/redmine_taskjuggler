# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateDepends < ActiveRecord::Migration
  def change
    create_table :tj_task_depends_task do |t|
      t.int :tj_task_id
      t.int :tj_task_depend_id
      t.float :gapvalue
      t.string :gapunits
      t.string :gaptype
      t.string :ontype # onend, onstart, or empty
      t.string :type # depends or preceeds
      t.date :start
      t.float :startcredit
      t.int :priority # Check to see if int or float
      t.float :length_duration_value
      t.string :length_duration_units
      t.date :maxstart
      t.date :minstart
      t.date :maxend
      t.date :minend
      t.int :milestone
      t.int :scheduled
      t.string :name
      t.string :code
      t.float :charge
      t.float :complete
      t.string :note # Should this be text? 
      t.timestamps
    end
    add_index(:tj_task, :tj_task_id)
    add_index(:tj_task, :project_id)
    add_index(:tj_task, :issue_id)
  end
end
