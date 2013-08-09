class AugmentProjectFields < ActiveRecord::Migration
  def up
    add_column :projects, :tj3_in, :boolean, default: false
    add_column :projects, :tj3_roottask, :string
    add_column :projects, :tj3_versions, :integer, defaut: 0
    add_column :projects, :tj3_categories, :integor, defaut: 0
    add_column :projects, :tj3_start_date, :date
    add_column :projects, :tj3_end_date, :date
  end
  def down
    remove_column :projects, :tj3_in
    remove_column :projects, :tj3_roottask
    remove_column :projects, :tj3_versions
    remove_column :projects, :tj3_categories
    remove_column :projects, :tj3_start_date
    remove_column :projects, :tj3_end_date
  end
end
