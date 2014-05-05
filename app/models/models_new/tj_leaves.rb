# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_account.rb
##
# The Leaves in TaskJuggler
class TjLeave < ActiveRecord::Base
  unloadable
  belongs_to :tj_project
  ##
  # Identifier 
  attr_accessor :code
  ##
  # Human-readable descriptor
  attr_accessor :name
  ##
  # date or interval
  attr_accessor :date_or_interval
end