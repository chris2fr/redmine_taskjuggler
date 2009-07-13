









version_name = "no_version"%>
	task no_version "Sans Version" {
		<% 
	cat_names = []
	@Cats.each do |cat| 
		cat_names.push(cat.name)
	end
	cat_names.push("no_category")
	cat_names.each do |cat_name|
		%><%= 
				render :file  => "/opt/redmine-0.8.4/vendor/plugins/redmine_tj_status/app/views/inc_cat.html.erb", :locals => { :cat_name => cat_name, :version_name => version_name } %><%
	end %>
	}
}














