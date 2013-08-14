json.array!(@redmine_taskjuggler_projects) do |redmine_taskjuggler_project|
  json.extract! redmine_taskjuggler_project, :active, :roottask, :start_date, :end_date, :dailyworkinghours, :timeformat
  json.url redmine_taskjuggler_project_url(redmine_taskjuggler_project, format: :json)
end
