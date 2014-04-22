class CreateRedmineTaskjugglerWorkloads < ActiveRecord::Migration
  def change
    create_table :redmine_taskjuggler_workloads do |t|
      t.integer :user_id
      t.date :current_date
      t.integer :interval
      
    end
    add_index(:redmine_taskjuggler_workloads, :user_id)
  end
end