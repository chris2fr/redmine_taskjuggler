# encoding: utf-8
##
#
module RedmineTaskjugglerViewListener
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_time_entries_bulk_edit_details_bottom, :partial => 'redmine_taskjuggler/time_entry/view_time_entries_bulk_edit_details_bottom')
    end
end

