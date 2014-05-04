# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjTasks< ActiveRecord::Migration
  def change
    create_table :tj_tasks do |t|
      t.string :name
      t.string :code
      t.int :tj_task_id
      t.int :project_id
      t.int :issue_id
      t.string :type
      t.timestamps
    end
    add_index(:tj_task, :tj_task_id)
    add_index(:tj_task, :project_id)
    add_index(:tj_task, :issue_id)
  end
end