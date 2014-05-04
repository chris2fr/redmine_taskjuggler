# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTj3Runs < ActiveRecord::Migration
  def change
    create_table :tj3_runs do |t|
      t.string :command
      t.string :options
      t.string :std_out
      t.string :std_error
      t.string :server
      t.string :port
      t.int :status
      t.string :type
      t.int :tjp_part_top
      t.int :tjp_part_project
      t.int :tjp_part_flags
      t.int :tjp_part_global
      t.int :tjp_part_macros
      t.int :tjp_part_accounts
      t.int :tjp_part_resources
      t.int :tjp_part_tasks
      t.int :tjp_part_bookings
      t.int :tjp_part_reports
      t.int :tjp_part_bottom
      t.timestamps
    end
    add_index(:tj3_runs, :tjp_part_top)
    add_index(:tj3_runs, :tjp_part_project)
    add_index(:tj3_runs, :tjp_part_flags)
    add_index(:tj3_runs, :tjp_part_global)
    add_index(:tj3_runs, :tjp_part_macros)
    add_index(:tj3_runs, :tjp_part_accounts)
    add_index(:tj3_runs, :tjp_part_resources)
    add_index(:tj3_runs, :tjp_part_tasks)
    add_index(:tj3_runs, :tjp_part_bookings)
    add_index(:tj3_runs, :tjp_part_reports)
    add_index(:tj3_runs, :tjp_part_bottom)
  end
end