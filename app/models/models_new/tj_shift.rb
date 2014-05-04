# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_account.rb
##
# The Account in TaskJuggler
class TjShift < ActiveRecord::Base
  unloadable
  ##
  # Sub-shifts
  has_many :tj_shifts
  ##
  # Identifier of the account
  attr_accessor :code
  ##
  # Name of the account
  attr_accessor :name
  ##
  # Value of the shift with leaves, replace, timezone, vacation, workinghours
  attr_accessor :leaves
  ##
  # replace
  attr_accessor :replace
  ##
  # timezone
  attr_accessor :timezone
  ##
  # vacation
  attr_accessor :vacation
  ##
  # workinghours
  attr_accessor :workinghours
end