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
  belongs_to :tj_task
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
  belongs_to:tj_projectS
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