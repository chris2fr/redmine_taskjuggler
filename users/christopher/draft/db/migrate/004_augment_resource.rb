class AugmentResource < ActiveRecord::Migration
  def up
    add_column :users, :tj3_squad, :string
    add_column :projects, :tj3_limits, :string
  end
  def down
    remove_column :projects, :tj3_squad
    remove_column :projects, :tj3_limits
  end
end
