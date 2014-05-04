# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# ActiveRectord Tj3. One such record is created for every
# command-line tj3 execution we run.
class Tj3Run < ActiveRecord::Base
  unloadable

  ##
  # output
  attr_accessible :output
  ##
  # error
  attr_accessible :error
  ##
  # options 
  attr_accessible :options
  ##
  # command 
  attr_accessible :command
  ##
  # options 
  attr_accessible :options
  ##
  # std_out 
  attr_accessible :std_out
  ##
  # std_error 
  attr_accessible :std_error
  ##
  # server 
  attr_accessible :server
  ##
  # port 
  attr_accessible :port
  ##
  # status 
  attr_accessible :status
  ##
  # type 
  attr_accessible :type
end