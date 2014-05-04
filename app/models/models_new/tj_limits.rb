# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_account.rb
##
# The Account in TaskJuggler
class TjLimitation < ActiveRecord::Base
  unloadable
  ##
  # The resource of the booking
  has_many :tj_leaf_resource
  ##
  # The task being booked
  has_one :tj_leaf_task
  ##
  # The temporal_application as start, start and end, interval
  has_one :temporal_application
  ##
  # The load limitation as weeklymax 5h for example
  attr_accessor :load
end