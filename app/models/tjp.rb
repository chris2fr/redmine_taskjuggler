# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# A utility resource. We are interested in the attached project.
# Later, this class could take on the role of a particular planning
# session by the TaskMaster.
class Tjp < ActiveRecord::Base
  unloadable
  belongs_to :projects
  has_one :datesupdate
  attr_accessible :filename,
    :content
end
