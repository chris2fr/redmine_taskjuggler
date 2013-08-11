#require 'redmine'
#
## Patches to the Redmine core. (Why do I do this ?)
#require 'dispatcher'
#require 'issue_patch'
#require 'user_patch'
#Dispatcher.to_prepare do
#  Issue.send(:include, IssuePatch)
#  Query.send(:include, UserPatch)
#end

Redmine::Plugin.register :redmine_taskjuggler do
  name 'Redmine Taskjuggler plugin'
  author 'Christopher Mann <christopher@mann.fr>'
  description 'This plug exports project status into TaskJuggler and imports the dates too !'
  version '0.1.0'
  url 'https://github.com/chris2fr/redmine_taskjuggler'
  author_url 'http://mann.fr'

  project_module :redmine_taskjuggler_module do
    # A public action
    permission :redmine_taskjuggler_index, {:redmine_taskjuggler => [:index]}, :public => true
    # This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :redmine_taskjuggler_admin, {:redmine_taskjuggler => [:admin]}
    # This permission can be given to project members only
    permission :redmine_taskjuggler_export, {:redmine_taskjuggler => [:import, :export]}, :require => :member
  end
  
  menu :project_menu, :redmine_taskjuggler, { :controller => 'redmine_taskjuggler', :action => "index" }, :caption => :redmine_taskjuggler_menu, :param => :project_id
  menu :admin_menu, :redmine_taskjuggler, {:controller => 'redmine_taskjuggler', :action => "admin"}, :caption => :redmine_taskjuggler_menu


  #menu	:project_menu, :taskjuggler, { :controller => 'redmine_taskjuggler', :action => 'index' }, :caption => :taskjuggler_label, :param => :project_identifier
  #permission :taskjuggler, {:taskjuggler => [:index, :export, :initial_export]}, :public => true
  #menu :project_menu, :taskjuggler, { :controller => 'taskjuggler', :action => 'test' }, :caption => 'Task Juggler File', :after => :activity, :param => :project_identifier
  #menu :application_menu, :tjstatus, { :controller => 'tjstatus', :action => 'index' }, :caption => 'Task Juggler'
end
