# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# ActiveRectord Boilerplate
class Tj3ResultingDates < ActiveRecord::Base
  unloadable
  belongs_to :projects
  belongs_to :tjp
end