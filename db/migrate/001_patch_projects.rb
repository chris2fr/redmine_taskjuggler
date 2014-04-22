class PatchProjects < ActiveRecord::Migration
  def change
    add_column :projects, :tj_activated, :boolean, :default => true
    add_column :projects, :tj_version, :string, :default => "0.0.0"
    add_column :projects, :tj_dailyworkinghours, :float, :default => "8.0"
    add_column :projects, :tj_period,  :string
    add_column :projects, :tj_currency,  :string
    add_column :projects, :tj_now,  :string
    add_column :projects, :tj_numberformat,  :string, :default => "'-' '' ',' '.' '3'"
    add_column :projects, :tj_timingresolution,  :string
    add_column :projects, :tj_timeformat, :string, :default => "%Y-%m-%d %H:%M"
  end
end