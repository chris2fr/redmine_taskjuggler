# Projects mirror projects in TaskJuggler

class CreateTj3projects < ActiveRecord::Migration
  def self.change 
    add_column :project, :tj_in, :boolean, default: false
    add_column :project, :tj_roottask, :string
    add_column :project, :tj_versions, :integer, defaut: 0
    add_column :project, :tj_categories, :integor, defaut: 0
    add_column :project, :tj_start_date, :date
    add_column :project, :tj_end_date, :date
end
