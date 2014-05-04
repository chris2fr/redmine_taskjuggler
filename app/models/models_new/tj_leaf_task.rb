# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_leaf_resource.rb
##
# This is a task we can book on.
class TjLeafTask < TjTask
  unloadable
  has_one :tj_composite_task
end