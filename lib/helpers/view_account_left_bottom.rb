module RedmineTaskjugglerViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_account_left_bottom, :partial => 'redmine_taskjuggler/user/view_account_left_bottom')
    end
end 