# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjShifts < ActiveRecord::Migration
  def change
    create_table :tj_shifts do |t|
      t.string :name
      t.string :code
      t.string :leaves
      t.string :replace
      t.string :timezone
      t.string :vacation
      t.string :workinghours
      t.int tj_shift_id
      t.timestamps
    end
    add_index(:tj_shifts, :tj_shift_id)
  end
end