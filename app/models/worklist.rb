class Worklist < ActiveRecord::Base
	has_many :user, :class_name => 'user', :foreign_key => 'user_id'
	has_many :issues, :class_name => 'issue', :foreign_key => 'issue_id'
end