require_dependency 'redmine_taskjuggler' 
#
# Redmine Taskjuggler main controller
#
class RedmineTaskjugglerController < ApplicationController
  unloadable
  
  # This is the index and only visible specific view
  def tjindex
    @project = Project.find(params[:id])
  end
  
  
  
  # This is a TJP download
  def tjp
    # Project hierarchy TaskJuggler creation
    def redmine_project_to_taskjuggler_task (project)
      tjTasks = {}
      tjTasks['versions'] = {}
      tjTasks['cats'] = {}
      tjTasks['issues'] = {}
      tjTasks['index'] = {}
      # The root task
      topTask = RedmineTaskjuggler::Taskjuggler::Task.new(
                  project.identifier.gsub(/-/,"_"),
                  project.name,
                  nil,[],[],project.description)
      tjTasks['versions'] = {}
      tjTasks['versions']['noversion'] = RedmineTaskjuggler::Taskjuggler::Task.new(
                  'noversion',
                  "Tasks not assigned to a Version",
                  topTask)
      tjTasks['index']['noversion'] = {}
      # Releases
      
      versions = project.versions.all
      versions.each {
        |version|
        if version.fixed_issues.size > 0
          version_id = version.name.gsub(/[- ]/,"_")
          taskVersion = RedmineTaskjuggler::Taskjuggler::Task.new(
                  version_id,
                  version.description,
                  topTask)
          tjTasks['versions'][version_id] = taskVersion
          tjTasks['index'][version_id] = {}
        end
      }
      
      # Getting all tasks and subtasks
      Issue.visible.where(project.project_condition(true)).find_each do |issue|
        unless issue.fixed_version
          version_id = 'noversion'
        else
          version_id = issue.fixed_version.name.gsub(/[- ],"_"/)
        end
        if issue.category
          cat_id = category.name.gsub(/[- ],"_"/)
          cat_name = category.name
        else
          cat_id = 'nocat'
          cat_name = "No Category"
        end
        unless tjTasks['cats'].has_key?(version_id)
          tjTasks['cats'][version_id] = {}
        end
        
        unless tjTasks['cats'][version_id].has_key?(cat_id)
          tjTasks['cats'][version_id][cat_id] = RedmineTaskjuggler::Taskjuggler::Task.new(
                cat_id,
                cat_name,
                tjTasks['versions'][version_id])
          tjTasks['index'][version_id][cat_id] = []
        end
        tjTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
          "[red#{issue.id}] " + issue.subject,
          tjTasks['cats'][version_id][cat_id],
          nil,
          [], #issue.tj_flags,
          issue.description
        )
        tjTasks['issues'][issue.id] = tjTask
        tjTasks['index'][version_id][cat_id].push(issue.id)
      end
      tjTasks['issues'].keys.each do |redID|
        irs = IssueRelation.find(:all,
                :conditions => {:issue_to_id => redID,
                  # Strangely enough, only preecedes is used, and not follows
                  # as does blocks and not blocked by
                  # TODO: think about the issue_relation duplicates as an invalidator
                  :relation_type => [IssueRelation::TYPE_PRECEDES,
                    IssueRelation::TYPE_BLOCKS
                  ]
                }
              )
        # message += " issue " + issue.id.to_s + " irs.size #{irs.size} \n"
        if irs.size > 0
          depends = []
          irs.each {
            |ir|
            depends.push(RedmineTaskjuggler::Taskjuggler::Depend.new(
                # TODO: Use the issue object to get the correct TaskJuggler ID
                tjTasks['issues'][ir.issue_from_id],
                RedmineTaskjuggler::Taskjuggler::Gap.new(
                  # TODO: the +1 is actually inaccurate here and needs adjusting with overload of issue or non-use of internal follows
                  unless ir.delay == nil
                    # TODO: Think about Redmines notion of delay with regards to the gap in TaskJuggler
                    RedmineTaskjuggler::Taskjuggler::TimeSpan.new(ir.delay.to_i + 1, 'd')
                  end
                )
              )
            )
          }
          start_point = RedmineTaskjuggler::Taskjuggler::TimePointDepends.new(depends)
        else
          start_point = RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
        end
        issue = Issue.find(redID)
        if issue.tj_allocates
          tjTasks['issues'][redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
            # TODO: Better determine start
            start_point,
            RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
            RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h')
          )
        #elsif issue.tj_milestone
        #  tjTasks[redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortMilestone.new(
        #    # TODO: Revisit TimePoint Null and TimePoint
        #    # TODO: The format of start might not suffice as such
        #    issue.start || RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
        #  )
        elsif issue.start_date? and issue.due_date?
          tjTasks['issues'][redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            # TODO: Revisit TimePoint Null and TimePoint
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
          )
        end
        # topTask.children.push(tjTasks['issues'][redID])
      end
      tjTasks['versions'].keys.each {
        |version_id|
        tjTasks['cats'][version_id].keys.each {
          |cat_id|
          tjTasks['index'][version_id][cat_id].each {
            |redid|
            tjTasks['cats'][version_id][cat_id].children.push(
              tjTasks['issues'][redid]
            )
            # puts 'debug'
            # puts tjTasks['issues'][redid].class
            #tjTasks['index'][version_id].children.push(
            #  tjTasks['cats'][version_id][cat_id]
            #)
          }
          tjTasks['versions'][version_id].children.push(
            tjTasks['cats'][version_id][cat_id]
          )
        }
        topTask.children.push(
          tjTasks['versions'][version_id]
        )
      }
      return topTask
    end
    
    
    #include RedmineTaskjuggler
    @project = Project.find(params[:id])
        tjProject = RedmineTaskjuggler::Taskjuggler::Project.new(@project.identifier.gsub("-","_"),
        @project.to_s,
        @project.tj_period.to_s,
        @project.tj_now.to_s,
        @project.tj_version.to_s,
        @project.tj_dailyworkinghours.to_s,
        @project.tj_timingresolution.to_s
        )
    tjResources = []
    User.where(tj_activated: true).find_each do |user|
        if user.login.to_s != ""
          tjResources.push(RedmineTaskjuggler::Taskjuggler::Resource.new(user.login.gsub(/-/,'_'),
                  user.firstname + ' ' + user.lastname,
                  user.tj_parent))
        end
    end
    
    topTask = redmine_project_to_taskjuggler_task(@project)
    
    tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,[topTask])
    #tjp = RedmineTaskjuggler::TJP.new()
    send_data tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + ".tjp", :type => 'text/plain'
  end
  
  # This is a CSV upload
  def csv
    # Get the CSV File
    uploaded_io = params[:csvfile]
    #if uploaded_io[0,19] != '"Id";"Start";"End"'
    #  raise l(:exception_not_csv_issue_update)
    #end
    @lines = []
    # Parse the CSV File line by line
    # Update Redmine with the dates and effort
    CSV.foreach(uploaded_io.tempfile, :headers => true, :col_sep => ';') {
      |csvline|
      if csvline["Redmine"].to_s != ""
        update_attributes = {
          'start_date' => csvline['Start'], 
          'due_date' => csvline['End']
        }      
        issue = Issue.find(csvline["Redmine"])
        test = true
        update_attributes.each { |r, t|  
          test = test & issue.update_attributes({r => t})
        }
        unless test
          @lines.push(issue.errors.messages.inspect.to_s)
        end
        @lines.push("#" + csvline["Redmine"].to_s + ". #{issue.subject} : #{issue.start_date} - #{issue.due_date} " ) # + link_to_issue(issue)
      end
    }
  end
end