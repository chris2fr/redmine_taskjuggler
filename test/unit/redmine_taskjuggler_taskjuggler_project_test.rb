# encoding: utf-8
##
#
require File.expand_path('../../test_helper', __FILE__)
require 'test/unit'
require 'redmine_taskjuggler'
class RedmineTaskjugglerTaskjugglerProjectTest < Test::Unit::TestCase
  include RedmineTaskjuggler
  def makeMeAProject
    Taskjuggler::Project.new('test', \
              'This is a Test Project', \
              '2013-01-01 - 2014-01-01', \
              '2013-06-06')
  end
  def makeMeATask
    task = Taskjuggler::Task.new('test', \
           'This is a Test Task')
    ##
    # TODO: Investigate impact of having five arguments instead of two
    task.timeEffort = Taskjuggler::TimeEffortStartSpan.new( \
                      Taskjuggler::TimePointStart.new('2013-02-02'),\
                      Taskjuggler::TimeSpan.new(5, 'd'))
    task
  end
  def makeMe27Tasks
    tasks = []
    for i in (1..3) do
      tasks.push(Taskjuggler::Task.new('task' + i.to_s,'Test Task ' + i.to_s))
      for j in (1..3) do
        tasks[i - 1].children.push(Taskjuggler::Task.new('task'+ i.to_s + j.to_s,'Test Task '+i.to_s + j.to_s,tasks[i - 1]))
        tasks[i - 1].children[j - 1].timeEffort = Taskjuggler::TimeEffortStartSpan.new( \
                      Taskjuggler::TimePointStart.new('2013-02-02'),\
                      Taskjuggler::TimeSpan.new(i, 'd'))
      end
    end
    depends = []
    depends.push(
      Taskjuggler::Depend.new(
        tasks[0].children[1],
        Taskjuggler::TimeSpan.new(5,'d')
      )
    )
    tasks[0].children[2].timeEffort.timePointStart = Taskjuggler::TimePointDepends.new(depends)
    tasks
  end
  def test_creation_project
    project = makeMeAProject
    assert_equal Taskjuggler::Project, project.class
  end
  def test_project_toTJP
    project = makeMeAProject
    tjp = TJP.new(project,[],[])
    assert_match "project test", tjp.to_s
  end
  def test_create_task
    task = makeMeATask
    assert_equal task.class, Taskjuggler::Task
  end
  def test_task_toTJP
    task = makeMeATask
    project = makeMeAProject
    tjp = TJP.new(project,[],[task])
    assert_match "task test", tjp.to_s
  end
  def test_nesteded_tasks_toTJP
    task = makeMeATask
    project = makeMeAProject
    task.children.push makeMeATask
    task.children[0].localId = "nested_task"
    tjp = TJP.new(project,[],[task])
    assert_match "task nested_task", tjp.to_s
  end
  ##
  # Creates a resource. The signature has changed.
  def test_create_resource
    resource = Taskjuggler::Resource.new('test','This is a test resource')
    assert_equal resource.class, Taskjuggler::Resource
  end
  def test_create_27_tasks
    tasks = makeMe27Tasks
    assert_equal tasks[2].children[2].class, Taskjuggler::Task
  end
  def test_make_tjp
    project = makeMeAProject
    tasks = makeMe27Tasks
    resources = [Taskjuggler::Resource.new('test','This is a test resource')]
    tjp = TJP.new(project, resources, tasks)
    assert_match(/task task32/, tjp.to_s)
  end
end
