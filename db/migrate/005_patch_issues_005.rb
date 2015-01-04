# encoding: utf-8
##
# Adding a field for extra stuff, whatever, in a task from an issue.
class PatchIssues005 < ActiveRecord::Migration
  def change
    add_column :issues, :tj_issue_etc, :string # Add arbitrary data to an issue
  end
end
