class PatchIssues005 < ActiveRecord::Migration
  def change
    add_column :issues, :tj_issue_etc, :string # Add arbitrary data to an issue
  end
end
