# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_account.rb
##
# The Account in TaskJuggler
class TjBooking < ActiveRecord::Base
  unloadable
  ##
  # The resource of the booking
  has_one :tj_resource
  ##
  # The task being booked
  has_one :tj_task
  ##
  # The task being booked
  attr_accessor :value
end