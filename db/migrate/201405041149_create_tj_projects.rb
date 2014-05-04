# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjProjects < ActiveRecord::Migration
  def change
    create_table :tj_projects do |t|
      t.string :code
      t.string :name
      t.string :version
      t.string :interval
      t.string :currency
      t.string :number_format
      t.string :time_format
      t.date :now
      t.timestamps
    end
  end
end