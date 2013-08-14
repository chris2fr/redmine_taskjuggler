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
    tasks
  end
  def test_creation_project
    project = makeMeAProject
    assert_equal Taskjuggler::Project, project.class
  end
  def test_project_toTJP
    project = makeMeAProject
    assert_match "project test", project.toTJP
  end
  def test_create_task
    task = makeMeATask
    assert_equal task.class, Taskjuggler::Task
  end
  def test_task_toTJP
    task = makeMeATask
    assert_match "task test", task.toTJP
  end
  def test_nesteded_tasks_toTJP
    task = makeMeATask
    task.children.push makeMeATask
    task.children[0].localId = "nested_task"
    assert_match "task nested_task", task.toTJP 
  end
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
    tjp = Taskjuggler::TJP.new(project, resources, tasks)
    assert_match(/task task32/, tjp.to_s)
  end
end
