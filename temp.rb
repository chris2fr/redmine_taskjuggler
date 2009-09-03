









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
				render :file  => File.join(File.direname(__FILE__), "app","views","inc_cat.html.erb"), :locals => { :cat_name => cat_name, :version_name => version_name } %><%
	end %>
	}
}














