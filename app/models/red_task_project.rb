# require_dependency 'project'
#require_dependency 'modules/red_task_project' 
class RedTaskProject < ActiveRecord::Base
  unloadable
  attr_accessible  :project_id, :active, :roottask,
    :start_date, :end_date, :dailyworkinghours,
    :timeformat
  belongs_to :project
  #include RedTaskProject
end