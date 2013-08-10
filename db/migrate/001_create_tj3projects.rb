# Projects mirror projects in TaskJuggler

class CreateTJProjects < ActiveRecord::Migration
  def self.change
    add_column :projects, :tj3_in, :boolean, default: false
    add_column :projects, :tj3_roottask, :string
    add_column :projects, :tj3_versions, :integer, defaut: 0
    add_column :projects, :tj3_categories, :integor, defaut: 0
    add_column :projects, :tj3_start_date, :date
    add_column :projects, :tj3_end_date, :date
  end
end
