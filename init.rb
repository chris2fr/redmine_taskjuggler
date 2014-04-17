# Patches to the Redmine core.

ActionDispatch::Callbacks.to_prepare do
  require 'initializers/issue'
  require 'initializers/project'
  require 'initializers/user'
  require 'initializers/time_entry'
end

require_dependency 'helpers/view_account_left_bottom'
require_dependency 'helpers/view_issues_bulk_edit_details_bottom'
require_dependency 'helpers/view_issues_form_details_bottom'
require_dependency 'helpers/view_issues_show_description_bottom'
require_dependency 'helpers/view_projects_form'
require_dependency 'helpers/view_projects_show_left'
require_dependency 'helpers/view_time_entries_bulk_edit_details_bottom'
require_dependency 'helpers/view_timelog_edit_form_bottom'
require_dependency 'helpers/view_users_form'

require_dependency 'redmine_taskjuggler/application'

puts RedmineTaskjuggler::Application.instance.version

Redmine::Plugin.register :redmine_taskjuggler do
  name 'Redmine Taskjuggler plugin'
  author 'Christopher Mann <christopher@mann.fr>'
  description 'This plug exports project status into TaskJuggler and imports the dates too !'
  version '0.1.master'
  url 'https://github.com/chris2fr/redmine_taskjuggler'
  author_url 'http://mann.fr'

  permission :redmine_taskjuggler, { :redmine_taskjuggler => [:tjindex, :tjp, :csv] }, :public => true
  # This permission has to be explicitly given
  # It will be listed on the permissions screen
  # permission :redmine_taskjuggler_admin, {:redmine_taskjuggler => [:admin]}
  # This permission can be given to project members only
  # permission :redmine_taskjuggler_member, {:redmine_taskjuggler => [:import, :export]}, :require => :member


  menu :project_menu, :redmine_taskjuggler, {
    :controller => 'redmine_taskjuggler',
    :action => 'tjindex'
  }, :after => :activity, :caption => :taskjuggler, :param => :id
  
  # menu :application_menu, :redmine_taskjuggler, { :controller => 'redmine_taskjuggler_projects', :action => 'index' }, :caption => :tj_project
  
end
