module RedmineTaskjugglerViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_issues_bulk_edit_details_bottom, :partial => 'redmine_taskjuggler/issue/view_issues_bulk_edit_details_bottom')
    end
end 