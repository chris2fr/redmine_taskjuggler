class CreateIssuesUsers < ActiveRecord::Migration
  def self.up
	create_table "issues_users", :id => false do |t| 
		t.integer "user_id"
		t.integer "issue_id" 
	end
  end

  def self.down
    drop_table "issues_users"
  end
end
