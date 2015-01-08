# encoding: utf-8
##
# I don't think I use this at all and can delete it.
# The technique instead is to use the watch list from Redmine.
class Worklist < ActiveRecord::Base
  has_many :user, :class_name => 'user', :foreign_key => 'user_id'
  has_many :issues, :class_name => 'issue', :foreign_key => 'issue_id'
end
