require 'redmine'

Redmine::Plugin.register :redmine_task_juggler do
author 'Chris Mann'
  description 'This plug exports project status into TaskJuggler and will import the dates too !'
  version '0.0.2'
  #menu :application_menu, :tjstatus, { :controller => 'tjstatus', :action => 'index' }, :caption => 'Task Juggler'
  permission :task_juggler, {:task_juggler => [:index, :tjfile]}, :public => true
  menu :project_menu, :tjstatus, { :controller => 'tjstatus', :action => 'test' }, :caption => 'Task Juggler File', :after => :activity, :param => :project_identifier
end
