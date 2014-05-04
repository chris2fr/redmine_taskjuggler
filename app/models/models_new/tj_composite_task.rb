# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_composite_task.rb
##
# This is a task that contains other tasks
class TjCompositeTask < TjTask
  unloadable
  has_many :tj_tasks
  has_many :tj_allocations
  ##
  # The corresponding issue
  has_one :issue
end