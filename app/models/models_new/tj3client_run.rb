# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# ActiveRectord Tj3Client represents an execution of the tj3_client
class Tj3Client < Tj3
  unloadable
  attr_accessible server,
    port
  
end