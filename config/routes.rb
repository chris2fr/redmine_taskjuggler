# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get '/tj3project/:project_identifier', to: 'redmine_taskjuggler#initial_export'
get '/hello', to: 'redmine_taskjuggler#hello'
get '/tjadmin', to: 'redmine_taskjuggler#tjadmin'