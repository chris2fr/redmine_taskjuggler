# Patches to the Redmine core.

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_taskjuggler/patch/issue'
  require 'redmine_taskjuggler/patch/project'
  require 'redmine_taskjuggler/patch/user'
  require 'redmine_taskjuggler/patch/time_entry'
end

require_dependency 'redmine_taskjuggler/helpers/view_issues_show_details_bottom'
require_dependency 'redmine_taskjuggler/helpers/view_projects_form'
require_dependency 'redmine_taskjuggler/helpers/view_timelog_edit_form_bottom'
require_dependency 'redmine_taskjuggler/helpers/view_users_form'

Redmine::Plugin.register :redmine_taskjuggler do
  name 'Redmine Taskjuggler plugin'
  author 'Christopher Mann <christopher@mann.fr>'
  description 'This plug exports project status into TaskJuggler and imports the dates too !'
  version '0.1.0'
  url 'https://github.com/chris2fr/redmine_taskjuggler'
  author_url 'http://mann.fr'

  permission :redmine_taskjuggler, { 
	:redmine_taskjuggler => [:show] }, :public => true
	# This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :redmine_taskjuggler_admin, {:redmine_taskjuggler => [:admin]}
    # This permission can be given to project members only
    permission :redmine_taskjuggler_member, {:redmine_taskjuggler => [:import, :export]}, :require => :member


  menu :project_menu, :redmine_taskjuggler_projects, { :controller => 'redmine_taskjuggler', :action => 'show' }, 
  :after => :activity, :caption => :taskjuggler, :param => :id
  
  # menu :application_menu, :redmine_taskjuggler, { :controller => 'redmine_taskjuggler_projects', :action => 'index' }, :caption => :tj_project
  
end
