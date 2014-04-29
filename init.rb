# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : init.rb
# Code for integrating redmine_taskjuggler into Redmine

require 'redmine'

##
# Patches to the Redmine core.
ActionDispatch::Callbacks.to_prepare do
  require 'initializers/issue'
  require 'initializers/project'
  require 'initializers/user'
  require 'initializers/time_entry'
end

##
# Dependency helpers or hooks I suppose
require_dependency 'helpers/view_account_left_bottom'
require_dependency 'helpers/view_issues_bulk_edit_details_bottom'
require_dependency 'helpers/view_issues_form_details_bottom'
require_dependency 'helpers/view_issues_show_description_bottom'
require_dependency 'helpers/view_projects_form'
require_dependency 'helpers/view_projects_show_left'
require_dependency 'helpers/view_time_entries_bulk_edit_details_bottom'
require_dependency 'helpers/view_timelog_edit_form_bottom'
require_dependency 'helpers/view_users_form'

##
# Dependency application logic components from outside.
require_dependency 'redmine_taskjuggler/application'
require_dependency 'redmine_workload/application'

##
# Register the plugin with the conventional call
Redmine::Plugin.register :redmine_taskjuggler do
  name 'Redmine Taskjuggler plugin'
  author 'Christopher Mann <christopher@mann.fr>'
  description 'This plug exports project status into TaskJuggler and imports the dates too !'
  version '0.1.master'
  url 'https://github.com/chris2fr/redmine_taskjuggler'
  author_url 'http://mann.fr'

  ##
  # Add a permission
  permission :redmine_taskjuggler_projects, {
    :redmine_taskjuggler_projects => [:show, :index, :tjp, :csv]
  },
  :public => true
  
  # This permission has to be explicitly given
  # It will be listed on the permissions screen
  # permission :redmine_taskjuggler_admin, {:redmine_taskjuggler => [:admin]}
  # This permission can be given to project members only
  # permission :redmine_taskjuggler_member, {:redmine_taskjuggler => [:import, :export]}, :require => :member

  ##
  # Add a menu in the project
  menu :project_menu, :redmine_taskjuggler_projects, {
    :controller => 'redmine_taskjuggler_projects',
    :action => 'show'#,
    #:id => @project.id,
    #:set_filter => 1
  },
  :caption => :taskjuggler,
  :after => :activity
  
  ##
  # Add a menu in the Administration part of the application
  # TODO: find an image icon for the menu in the administration part of the application
  menu :admin_menu, :redmine_taskjuggler_teams, {
    :controller => 'redmine_taskjuggler_teams',
    :action => 'index'
  },
  :caption => 'teams'
  
  ##
  # Add a menu on the top-right for the user to see his or her workload
  menu :account_menu, :redmine_taskjuggler_workloads, {
    :controller => 'redmine_taskjuggler_workloads',
    :action => 'index'
  },
  :caption => :workload_label
  
  ##
  # Add an application-wide settings hash for plugin global settings
  settings :default => { 'tjp_path' => "",
			 'empty' => true},
	   :partial => 'settings/redmine_taskjuggler_settings'
  
  # menu :application_menu, :redmine_taskjuggler, { :controller => 'redmine_taskjuggler_projects', :action => 'index' }, :caption => :tj_project
  
end
