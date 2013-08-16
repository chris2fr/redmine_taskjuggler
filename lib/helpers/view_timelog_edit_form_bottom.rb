module RedmineTaskjugglerViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_timelog_edit_form_bottom, :partial => 'redmine_taskjuggler/time_entry/view_timelog_edit_form_bottom')
    end
end

