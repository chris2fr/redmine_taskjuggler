# Issues mirror tasks in TaskJuggler

class CreateTJIssues < ActiveRecord::Migration
  def self.change
    add_column :issues, :tj3_in, :boolean, default: false
    add_column :issues, :tj3_depends, :integer
    add_column :issues, :tj3_depends_gaplength_days, :number
    add_column :issues, :tj3_allocate, :string
    add_column :issues, :tj3_allocate2, :string
    add_column :issues, :tj3_flags, :string
    add_column :issues, :tj3_milestone, :boolean
    add_column :issues, :tj3_scheduled, :boolean
  end
end
