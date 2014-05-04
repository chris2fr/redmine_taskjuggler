# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjExtends < ActiveRecord::Migration
  def change
    create_table :tj_extends do |t|
      t.string :value
      t.timestamps
    end
  end
end