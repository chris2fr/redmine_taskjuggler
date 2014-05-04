# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjpFileParts < ActiveRecord::Migration
  def change
    create_table :tjp_file_parts do |t|
      t.string :file_name
      t.string :folder
      t.string :content
      t.date :start_date
      t.date :end_date
      t.string :project_name
      t.string :project_version
      t.string :currency
      t.string :number_format
      t.string :time_format
      t.float 
      t.string :type
      t.int :tjp_file_part_id
      t.timestamps
    end
    add_index(:tjp_file_parts, :tjp_file_part_id)
  end
end