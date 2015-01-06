#encoding: utf-8

module RedmineTaskjuggler
  ##
  # TJP represents the TJP file for taskjuggler computation
  class TJP
    ##
    # Where the file will be deposited, full path
    attr_accessor :file_path
    ##
    # Project associated
    attr_accessor :project
    ##
    # Array of Resource associated, or perhaps a nested set of Resource ,
    # I am not sure.
    attr_accessor :resources
    ##
    # Array of strings I think
    attr_accessor :flags
    ##
    # Array or nested set of Task
    attr_accessor :task
    ##
    # Array of Booking
    attr_accessor :bookings

    ##
    # Constructor. Needs +project+ Project , +resources+ Resource , +task+ Task ,
    # +flags+ an array of strings , +bookings+ Booking
    def initialize (project, resources, task, flags = [], bookings = [])
      @project = project
      @resources = resources
      @task = task
      @flags = flags
      @bookings = bookings

      unless @flags.include?('RedmineIssue')
        @flags.push('RedmineIssue')
      end
    end

    ##
    # A string representation of a project. In the future, we should use Project.to_s
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

    ##
    # A String representation of a task. In the future, we should use
    # Task.to_s
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

    ##
    # A string representation of the Resource . In the future we should use
    # Resource.to_s
    def resource_to_s (resource)
      tjpString = "resource #{resource.id.gsub(/\./,'_')} \"#{resource.name}\" {\n"
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

    ##
    # Added by Russians for including reports
    # TODO see if we can put this in parameters in Settings as either a text field or file (uploaded) or both
    def incl_file
      tjpString = "\n"
      tjpString += "flags team, hidden" + "\n"
      tjpString += "account cost \"Costs\"" + "\n"
      tjpString += "account rev \"Payments\"" + "\n"
      tjpString += "include \"reports.tji\""
      tjpString += "\n" + "\n"
    end

    ##
    # Returns Taskjuggler TJP representation
    def to_s
      tjpString = project_to_s(@project)
      team = nil
      @resources.each {|res|
        if team != res.team
          if team != nil
            tjpString += "}\n"
          end
          tjpString += "resource " + res.team + " \"" + res.team + "\" {\n"
          team = res.team
        end
        tjpString += resource_to_s(res)
      }
      tjpString += "}\n"
      if @flags != []
        tjpString += "flags " + flags.join(", ") + "\n"
      end
      tjpString << incl_file
      tjpString << task_to_s(@task)  + "\n"
      if @bookings.size > 0
        @bookings.each {|book|
          tjpString << book.to_s.gsub(/^/,"  ") + "\n"
        }
      end
      tjpString += <<EOREPORT
taskreport redmine_update_issues_csv_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_csv_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {
  formats csv
  hidetask ~RedmineIssue
  columns Redmine, start, end, effort, effortdone, priority
  balance cost rev
}
EOREPORT

      tjpString += <<EOREPORT
taskreport redmine_update_issues_html_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_html_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {
  formats html
  hidetask ~RedmineIssue
  columns no, name, start, end, effort, effortdone, priority, chart
  balance cost rev
}
EOREPORT

      return tjpString

end
  end
end
