module RedmineTaskjugglerProjectViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_projects_form, :partial => 'redmine_taskjuggler/project/view_projects_form')
    end
end

