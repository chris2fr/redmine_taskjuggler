# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)
require 'test/unit'
require 'redmine_taskjuggler'
##
# A Redmine Project for testing
class RedmineTaskjugglerTaskjugglerProjectTest < Test::Unit::TestCase
  include RedmineTaskjuggler
  ##
  # Creates a test project Redmine::Project
  def test_create_project
    project = Redmine::Project.new(1,'test','A Test Project')
    assert_equal Redmine::Project, project.class
  end
  ###
  ## Creates a pathed project, but I think no longer necessary
  #def test_create_patched_project
  #  project = Redmine::Project.new(1,'test','A Test Project')
  #  ## FIXME: What was Liason ? Now what I call a helper ?
  #  project.extend(RedmineTaskjuggler::Patch::Project)
  #  project.tj_now = '2013-06-06'
  #  assert_equal String, project.tj_now.class
  #end
end
