# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_flag.rb
##
# The Flag in TaskJuggler
class TjAccount < ActiveRecord::Base
  unloadable
  ##
  # The flag itself is an identifier
  attr_accessor :code
  def to_s
    code
  end
end