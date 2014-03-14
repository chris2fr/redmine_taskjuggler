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

	# Getting all tasks with subtasks
	unless issue.parent

	  # Add condition for use only activated issues
	  if issue.tj_activated == true
            tjTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
              "[red#{issue.id}] " + issue.subject,
              tjTasks['cats'][version_id][cat_id], 
              child_task(issue, project),
              [], #issue.tj_flags,
              issue.description
            )
            tjTasks['issues'][issue.id] = tjTask
            tjTasks['index'][version_id][cat_id].push(issue.id)
	  end
	  ###

	end
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
	if issue.tj_scheduled == true # fixed dates
	  tjTasks['issues'][redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
          )
        elsif issue.tj_allocates.to_s.length != 0
          if start_point.toTJP == ""
	
		   unless issue.children.to_s == "[]"
	              tjTasks['issues'][redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                        RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                        [],
	                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                      )
		    else
		      tjTasks['issues'][redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                        RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                        RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
	                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                      )
		    end
	  else

	  tjTasks['issues'][redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
            # TODO: Better determine start
            start_point,
            RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
            RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
	    RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	    RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
        )
	  end    
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
		  user.tj_limits,	# add limits, vacations and rate for Resource
		  user.tj_vacations,	#
		  user.tj_rate,		#
                  user.tj_parent))
        end	
    end
    
    topTask = redmine_project_to_taskjuggler_task(@project)
    
    tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,[topTask])
    #tjp = RedmineTaskjuggler::TJP.new()

    # Uniq name with time
    time = Time.now
    t_year = time.year.to_s;
    if time.month.to_s.length > 1
      t_month = time.month.to_s
    else 
      t_month = '0'+time.month.to_s
    end
    if time.day.to_s.length > 1
      t_day = time.day.to_s
    else 
      t_day = '0'+time.day.to_s
    end
    if time.hour.to_s.length > 1
      t_hour = time.hour.to_s
    else 
      t_hour = '0'+time.hour.to_s
    end
    if time.min.to_s.length > 1
      t_min = time.min.to_s
    else 
      t_min = '0'+time.min.to_s
    end
    if time.sec.to_s.length > 1
      t_sec = time.sec.to_s
    else 
      t_sec = '0'+time.sec.to_s
    end
    $time_str = t_year + t_month + t_day + '_' + t_hour + t_min + t_sec

    send_data tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + "-" + $time_str + ".tjp", :type => 'text/plain'
    ###
#    send_data tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + ".tjp", :type => 'text/plain'
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

  # Method to display the subtask
  def child_task(issue, project)
    tjTaskChildren = []
	if issue.children
	  issue.children.each {|child|

	 if child.tj_activated == true # if subtask is activated
	  tjTaskChild = RedmineTaskjuggler::Taskjuggler::Task.new('red' + child.id.to_s,
          "[red#{child.id}] " + child.subject,
          parent_task(child.parent, project),
          child_task(child, project),
          [], #issue.tj_flags,
          child.description
          )

	     redID = child.id
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
               if irs.size > 0
                 depends = []
                 irs.each {
                   |ir|
		     issue_depend = Issue.find(ir.issue_from_id)
                       depends.push(RedmineTaskjuggler::Taskjuggler::Depend.new(
                           # TODO: Use the issue object to get the correct TaskJuggler ID
			  RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue_depend.id.to_s,
          		  "[red#{issue_depend.id}] " + issue_depend.subject,
          		  parent_task(issue_depend.parent, project), 
          		  child_task(issue_depend, project),
          		  [], #issue.tj_flags,
          		  issue_depend.description
          		  ),
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

	       if child.tj_scheduled == true # fixed dates
	         tjTaskChild.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
                   RedmineTaskjuggler::Taskjuggler::TimePointStart.new(child.start_date),
                   RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(child.due_date)
                 )
               elsif child.tj_allocates.to_s.length != 0
                 if start_point.toTJP == ""
		    unless child.children.to_s == "[]"
	              tjTaskChild.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(child.start_date),
                        RedmineTaskjuggler::Taskjuggler::Allocate.new([child.tj_allocates]),
                        [],
	                RedmineTaskjuggler::Taskjuggler::Priority.new([child.tj_priority]),   # add Priority for Issue
	                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([child.tj_limits])    # add Limits for Issue
                      )
		    else
		      tjTaskChild.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(child.start_date),
                        RedmineTaskjuggler::Taskjuggler::Allocate.new([child.tj_allocates]),
                        RedmineTaskjuggler::Taskjuggler::TimeSpan.new(child.estimated_hours,'h'),
	                RedmineTaskjuggler::Taskjuggler::Priority.new([child.tj_priority]),   # add Priority for Issue
	                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([child.tj_limits])    # add Limits for Issue
                      )
		    end
	          else
	            tjTaskChild.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
                     # TODO: Better determine start
                      start_point,
	              RedmineTaskjuggler::Taskjuggler::Allocate.new([child.tj_allocates]),
                      RedmineTaskjuggler::Taskjuggler::TimeSpan.new(child.estimated_hours,'h'),
	              RedmineTaskjuggler::Taskjuggler::Priority.new([child.tj_priority]),   # add Priority for Issue
	              RedmineTaskjuggler::Taskjuggler::TaskLimits.new([child.tj_limits])    # add Limits for Issue
                   )
	          end    
	
               elsif child.start_date? and child.due_date?
                 tjTaskChild.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
                   # TODO: Revisit TimePoint Null and TimePoint
                   RedmineTaskjuggler::Taskjuggler::TimePointStart.new(child.start_date),
                   RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(child.due_date)
                 )
               end
	 end
	 if child.tj_activated == true
	  tjTaskChildren.push(tjTaskChild)
	 end
	  }
	end
	
    return tjTaskChildren
    
  end
  ###

  # Method for determening the parent task
  def parent_task(issue_par, project)

      tjTasks = {}
      tjTasks['versions'] = {}
      tjTasks['cats'] = {}
      tjTasks['issues'] = {}
      tjTasks['index'] = {}
      
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
      
      Issue.visible.where(project.project_condition(true)).find(issue_par) 
        unless issue_par.fixed_version
          version_id = 'noversion'
        else
          version_id = issue_par.fixed_version.name.gsub(/[- ],"_"/)
        end
        if issue_par.category
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

      parentTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue_par.id.to_s,
          "[red#{issue_par.id}] " + issue_par.subject,
          if issue_par.parent
	    parent_task(issue_par.parent, project)
	  else tjTasks['cats'][version_id][cat_id]
	  end, 
	  [],
          [],
          issue_par.description
          )

	return parentTask
  end
  ###

end
