# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjScenarios < ActiveRecord::Migration
  def change
    create_table :tj_scenarios do |t|
      t.int :tj_scenario_id
      t.string :code
      t.string :name
      t.timestamps
    end
    add_index(:tj_scenarios, :tj_scenario_id)
  end
end