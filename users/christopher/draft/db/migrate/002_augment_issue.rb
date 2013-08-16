class AugmentIssueFields < ActiveRecord::Migration
  def up
    add_column :issues, :tj3_in, :boolean, default: false
    add_column :issues, :tj3_depends, :integer
    add_column :issues, :tj3_depends_gaplength_days, :number
    add_column :issues, :tj3_allocate, :string
    add_column :issues, :tj3_allocate2, :string
    add_column :issues, :tj3_flags, :string
    add_column :issues, :tj3_milestone, :boolean
    add_column :issues, :tj3_scheduled, :boolean
  end
  def down
    remove_column :issues, :tj3_in
    remove_column :issues, :tj3_depends
    remove_column :issues, :tj3_depends_gaplength_days
    remove_column :issues, :tj3_allocate
    remove_column :issues, :tj3_allocate2
    remove_column :issues, :tj3_flags
    remove_column :issues, :tj3_milestone
    remove_column :issues, :tj3_scheduled
  end
end
