module RedmineTaskjugglerTimeEntryFormViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_users_form, :partial => 'redmine_taskjuggler/user/view_users_form')
    end
end
