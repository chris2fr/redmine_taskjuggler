# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_leaf_resource.rb
##
# The LeafResource in TaskJuggler
class TjLeafResource < ActiveRecord::Base
  unloadable
  ##
  # The corresponding user
  has_one :user
  ##
  # The code identifier
  attr_accessor :code
  ##
  # The name
  attr_accessor :name
end