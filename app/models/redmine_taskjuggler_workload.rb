# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# Setting this up as a resource, although it did not need to be,
# helps with the links and general management in Rails
class RedmineTaskjugglerWorkload < ActiveRecord::Base
  unloadable
  belongs_to :users
  ##
  # The user attached here
  # should this be attr_accessible instead ???
  attr_accessible :user_id
  ##
  # The current date around which the user inputs time entries (Redmine)
  attr_accessible :current_date
  ##
  # The before and after period we are looking at in summary views
  attr_accessible :interval 

  ##
  # Return the Redmine TimeEntry array with the current parameters
  def get_time_entries
    conditions = 'user_id = '+ @user_id.to_s() + ' AND spent_on > "' + (@current_date - @interval).to_s() + '" AND spent_on < "' + (@current_date + @interval).to_s() + '"'
    TimeEntry.find(:all,:conditions => [conditions], :order => ['issue_id,spent_on'] )
  end
  
end
