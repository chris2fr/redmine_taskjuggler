# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_macro.rb
##
# The Abstract Notion of a TaskJuggler Task
class TjTask < ActiveRecord::Base
  unloadable
  ##
  # TjTask The parent task 
  belongs_to :tj_task
  ##
  # TjAccount the account linked to this task
  has_one :tj_account
  ##
  # TjAllocate may become a has_many 
  has_one :tj_allocate
  ##
  # Depends on other tasks
  has_many :depends # Haven't yet created
  ##
  # Preceeds, like depends, but the other way
  has_many :preceeds
  ##
  # ShiftsIntervals that may be applied durring different time intervals
  has_many :shifts_intervals
  ##
  # Flags, just keywords, applicable for this task
  has_many :flags
  ##
  # JournalEntry different journal entries for a task
  has_many :journal_entries
  ##
  # LimitsTask applied to this task
  has_many :limits_tasks

  #has_one :tj_account as charge
  #has_one :tj_resource as responsible
  ##
  # Start of the task by default, actually minstart ASAP
  attr_accessor :start
  ##
  # Amount paid at the start of the task
  attr_accessor :startcredit
  ##
  # Priority of the task
  attr_accessor :priority
  ##
  # The length or duration
  attr_accessor :length_duration_value
  ##
  # Length or duration
  attr_accessor :length_duration_type
  ##
  # Max desired end
  attr_accessor :maxend, 
  :maxstart, :minend, :minstart
  ##
  # A more detailed note on the task
  attr_accessor :note
  ##
  # Tokens
  attr_accessor :milestone, :scheduled
  ##
  # Physical compleation of the task
  attr_accessor :complete
  ##
  # Amount paid at end of task
  attr_accessor :charge
  ##
  # The code identifier
  attr_accessor :code
  ##
  # The name
  attr_accessor :name
end

##
# This is a task that represents a project
class TjRootTask < TjTask
  unloadable
  has_one :project
  belongs_to :tj_projects
  
end

##
# This is a task that contains other tasks
class TjCompositeTask < TjTask
  unloadable
  has_many :tj_tasks # This is polymorphic
  has_many :tj_allocations
  ##
  # The corresponding issue
  has_one :issue
end

##
# This is a task we can book on.
class TjLeafTask < TjTask
  unloadable
  belongs_to :tj_composite_task
end
