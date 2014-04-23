# encoding: utf-8
##
#
require File.expand_path('../../test_helper', __FILE__)
require 'test/unit'
require 'redmine_taskjuggler'
class RedmineTaskjugglerTaskjugglerProjectTest < Test::Unit::TestCase
  include RedmineTaskjuggler
  def test_create_project
    project = Redmine::Project.new(1,'test','A Test Project')
    assert_equal Redmine::Project, project.class
  end
  def test_create_patched_project
    project = Redmine::Project.new(1,'test','A Test Project')
    project.extend(Liason::RedminePatch::Project)
    project.tjNow = '2013-06-06'
    assert_equal String, project.tjNow.class
  end
end
