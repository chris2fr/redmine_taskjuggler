# encoding: utf-8
# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :csvs
  resources :tjps
  resources :bookings
end

resources :issues do
  resources :bookings
end

resources :users do
  resources :bookings
end

resources :bookings
resources :csvs
resources :tjps

resources :teams

##
# Everything below is old






resources :redmine_taskjuggler_teams
resources :redmine_taskjuggler_workloads
resources :redmine_taskjuggler_projects


# get '/projects/:id/redmine_taskjuggler', to: 'redmine_taskjuggler_projects#show'



#get '/redmine_taskjuggler_project/view/:id', to: 'RedmineTaskjugglerProject#view'
#resources :redmine_taskjuggler_projects
#resources :redmine_taskjuggler

#post '/redmine_taskjuggler_teams/new', to: 'tj_teams#new'
#get '/redmine_taskjuggler_teams/detail/:id', to: 'tj_teams#detail'
#get '/redmine_taskjuggler_teams', to: 'tj_teams#index'

#get '/redmine_workload/timetable_summary', to: 'redmine_workload#timetable_summary'
#post '/redmine_workload/timetable_update', to: 'redmine_workload#timetable_update'
#get '/redmine_workload/timetable_update', to: 'redmine_workload#timetable_update'
#get '/redmine_workload/timetable', to: 'redmine_workload#timetable'
#get '/redmine_workload/summary', to: 'redmine_workload#summary'
#get '/redmine_workload/index', to: 'redmine_workload#index'
#get '/redmine_workload/', to: 'redmine_workload#index'

#get '/redmine_taskjuggler/:id', to: 'redmine_taskjuggler#tjindex'
#get '/redmine_taskjuggler/:id/tjp', to: 'redmine_taskjuggler#tjp'
get '/redmine_taskjuggler_projects/:id/tjp', to: 'redmine_taskjuggler_projects#tjp_save'
get '/redmine_taskjuggler_projects/:id/tjp_to_server', to: 'redmine_taskjuggler_projects#tjp_to_server'
post '/redmine_taskjuggler_projects/:id/csv', to: 'redmine_taskjuggler_projects#update'
