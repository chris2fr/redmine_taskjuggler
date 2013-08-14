module RedmineTaskjuggler 
    class ViewHookListener < Redmine::Hook::ViewListener
      render_on(:view_issues_form_details_bottom, :partial => 'redmine_taskjuggler/issue/show_taskjuggler_issue')
#      def view_issues_show_details_bottom(context={})
#        <<-EOHTML
#        <div id='tjIssueFields'>
#
#<dl>
#  <dt>tjScheduled:</dt>
#  <dd>#{@context[:issue].description}</dd>
#
#</dl>
#        </div>
#          EOHTML
#       end
    end 
end 