# encoding: utf-8
##
# A utility resource. We are interested in the attached project.
# Later, this class could take on the role of a particular planning
# session by the TaskMaster.
class RedmineTaskjugglerProjects < ActiveRecord::Base
  unloadable
  belongs_to :projects
end
