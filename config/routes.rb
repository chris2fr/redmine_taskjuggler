# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#get '/redmine_taskjuggler_project/view/:id', to: 'RedmineTaskjugglerProject#view'
#resources :redmine_taskjuggler_projects
#resources :redmine_taskjuggler

get '/redmine_taskjuggler/:id', to: 'redmine_taskjuggler#tjindex'
get '/redmine_taskjuggler/:id/tjp', to: 'redmine_taskjuggler#tjp'
post '/redmine_taskjuggler/:id', to: 'redmine_taskjuggler#csv'