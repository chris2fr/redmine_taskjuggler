# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# I don't think I use this at all and can delete it.
# The technique instead is to use the watch list from Redmine.
class Worklist < ActiveRecord::Base
	has_many :user, :class_name => 'user', :foreign_key => 'user_id'
	has_many :issues, :class_name => 'issue', :foreign_key => 'issue_id'
end