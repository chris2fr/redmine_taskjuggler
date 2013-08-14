module RedmineTaskjugglerIssueViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_issues_form_details_bottom, :partial => 'redmine_taskjuggler/issue/show_taskjuggler_issue')
    end
end 