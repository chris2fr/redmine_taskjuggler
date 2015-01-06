# encoding: utf-8
##
#
module RedmineTaskjugglerProjectViewListener
  class ViewHookListener < Redmine::Hook::ViewListener
    render_on(:view_projects_show_left, :partial => 'redmine_taskjuggler/project/view_projects_show_left')
  end
end

