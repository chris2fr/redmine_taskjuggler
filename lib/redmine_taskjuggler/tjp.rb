module RedmineTaskjuggler
  
  class TJP
    
    attr_accessor :file_path,
      :project,
      :resources,
      :flags,
      :tasks,
      :bookings
      
    def initialize (project, resources, tasks, flags = [], bookings = [])
      @project = project
      @resources = resources
      @tasks = tasks
      @flags = flags
      @bookings = bookings
    end
    
    def project_to_s (project)
        tjpString = "project #{project.id} \"#{project.name}\" \"#{project.version}\" #{project.period}  {\n"
        {'timeformat' => project.timeformat,
         'currency' => project.currency
         }.each do |k,v|
          if v and v != ""
            tjpString += "  " + k.to_s + " \"" + v + "\"\n"
          end
        end
        {'timingresolution' => project.timingresolution,
         'dailyworkinghours' => project.dailyworkinghours}.each do |k,v|
          if v and v != ""
            tjpString += "  " + k.to_s + " " + v.to_s + "\n"
          end
        end
    
        tjpString += "  extend task {\n"
        tjpString += "    number Redmine 'Redmine'\n" 
        tjpString += "  }\n"
        tjpString += "  now #{project.now}\n"
        tjpString += "}\n"

        return tjpString
    end
    
    def task_to_s (task)
        tjpString = "task #{task.localId} \"#{task.name}\" {\n"
        if task.timeEffort != nil
          tjpString += task.timeEffort.toTJP.gsub(/^/,"  ") + "\n"
        end
        # TODO: More elegant solution for determining if concerned task
        if task.localId[0,3] == 'red'
          tjpString += "  Redmine #{task.localId[3,task.localId.size]}\n"
        end
        if task.flags.class == Array and task.flags != []
          tjpString += "  flags " + flags.join(", ")
        end
        if task.note.class == String and task.note != ""
          tjpString += <<EOS
  note -8<-
#{task.note.gsub(/\"/,'\\"').gsub(/^/,'  ')}
  ->8-
EOS
        end
        if task.children.class == Array and task.children != []
          task.children.each {|child|
            tjpString += task_to_s(child).gsub(/^/,"  ") + "\n"
          }
        end
        tjpString += "}"
        return tjpString
    end
    
    def resource_to_s (resource)
        tjpString = "resource #{resource.id} \"#{resource.name}\" {\n"
        if resource.children != []
          resource.children.each {|child|
            tjpString += resource_to_s(child).gsub(/^/, "  ") + "\n"
          }
        end
        tjpString += "}\n"
        tjpString
    end
    
    def booking_to_s (booking)
        tjpString = "supplement task #{booking.task_id} {\n  booking #{booking.resource_id} "
        @booking.periods.each {|per|
          tjpString += per.toTJP + ", "
        }
        tjpString[0, -2] + "\n}"
    end
    
    # Returns Taskjuggler TJP representation
    def to_s
      tjpString = project_to_s(@project)
      @resources.each {|res|
        tjpString += resource_to_s(res)
      }
      if @flags != []
        tjpString += "flags " + flags.join(", ")
      end
      @tasks.each {|task|
        tjpString += task_to_s(task)  + "\n"
      }
      if @bookings.size > 0
        @bookings.each {|book|
          tjpString += booking_to_s(book).gsub(/^/,"  ") + "\n"
        }
      end
      tjpString += <<EOREPORT
taskreport redmine_update_issues_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {
  formats csv
  columns Redmine, start, end, effort, effortdone, priority, depends
}
EOREPORT
      tjpString
    
    end
  end
end