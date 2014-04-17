#encoding: utf-8

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
      
      unless @flags.include?('RedmineIssue')
        @flags.push('RedmineIssue')
      end
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
        if project.now.to_s != ""
          tjpString += "  now #{project.now}\n"
        end
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
        task.flags.push('RedmineIssue')
        if task.flags.class == Array and task.flags != []
          tjpString += "  flags " + task.flags.join(", ") + "\n"
        end
        if task.issueEtc.class == String and task.issueEtc !=""
	  tjpString += task.issueEtc.gsub(/^/,'  ') + "\n" # Might be one indentation too much
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
	
	# limits, vacation and rate displayed in tjp-file
	tjpString += "limits " + "{" + "#{resource.limits}" + "}\n"
	if resource.vacations != ""
	    tjpString += "#{resource.vacations}" + "\n"
	end	  
	if resource.rate.to_s.length != 0
	    tjpString += "rate " + "#{resource.rate}" + "\n"
	end	  
	###    
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
        tjpString += "flags " + flags.join(", ") + "\n"
      end
      @tasks.each {|task|
	tjpString << task_to_s(task)  + "\n"
      }
      if @bookings.size > 0
        @bookings.each {|book|
          tjpString << booking_to_s(book).gsub(/^/,"  ") + "\n"
        }
      end
      tjpString += <<EOREPORT
taskreport redmine_update_issues_csv_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_csv_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {
  formats csv
  hidetask ~RedmineIssue
  columns Redmine, start, end, effort, effortdone, priority
}
EOREPORT

      tjpString += <<EOREPORT
taskreport redmine_update_issues_html_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_html_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {
  formats html
  hidetask ~RedmineIssue
  columns no, name, start, end, effort, effortdone, priority, chart
}
EOREPORT

      tjpString
    
    end
  end
end
