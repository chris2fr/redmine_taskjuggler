# encoding: utf-8
##
#
module RedmineTaskjugglerIssueViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_issues_show_description_bottom, :partial => 'redmine_taskjuggler/issue/view_issues_show_description_bottom')
    end
end 