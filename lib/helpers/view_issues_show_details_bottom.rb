module RedmineTaskjugglerIssueViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_issues_show_details_bottom, :partial => 'redmine_taskjuggler/issue/view_issues_show_details_bottom')
    end
end 