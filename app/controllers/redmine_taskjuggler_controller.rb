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
    def redmine_project_to_taskjuggler_task(project)
      if project.children.to_s == "[]"
	 topTask = project_to_taskjuggler_task(project) # if we choose only one subproject (project)
      else
	topTask = subproject_to_taskjuggler_task(project) # if we choose main project (all subprojects/all tasks)       
      end
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
   
    tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,topTask)

#    send_data tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + ".tjp", :type => 'text/plain'
  end

  # Save tjp-file to computer
  def tjp_save
    project = Project.find(params[:id])
    f_name = project.identifier + "-" + project.tj_version.to_s.gsub(/\./,"_")  + ".tjp"
    data = tjp.to_s

    send_data data, :filename => f_name, :type => 'text/plain'
    end

  # Save tjp-file to server
  def tjp_to_server
    project = Project.find(params[:id])
    f_name = project.identifier + "-" + project.tj_version.to_s.gsub(/\./,"_")  + ".tjp"
    data = tjp.to_s
    Dir.chdir "/tmp"
    File.write(f_name, data)
    redirect_to :back
  end

  # This is a CSV upload
  def csv
    project = Project.find(params[:id])
    # Get the CSV File
    uploaded_io = params[:csvfile]
    #if uploaded_io[0,19] != '"Id";"Start";"End"'
    #  raise l(:exception_not_csv_issue_update)
    #end
    @lines = []
    # Parse the CSV File line by line
  
    if uploaded_io    # Condition for updating csv from computer of from server
      data = uploaded_io.tempfile
	else
	  path = "/tmp"
	  name_f = "redmine_update_issues_csv_" + project.identifier + "_" + project.tj_version.to_s.gsub(/\./,"_")  + ".csv"
	  data = "#{path}#{name_f}"
	end

    # Update Redmine with the dates and effort
#    CSV.foreach(uploaded_io.tempfile, :headers => true, :col_sep => ';') {
    CSV.foreach(data, :headers => true, :col_sep => ';') {
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

  # Method using if chosen main project (all subprojects/ all tasks)
  def subproject_to_taskjuggler_task(project)
    tjSubprj = []
    subprojects = project.children
    subprojects.each {|subproject|
    tjTasks = []
    topTask = RedmineTaskjuggler::Taskjuggler::Task.new(subproject.identifier.gsub(/-/,"_"),
      subproject.name,
      nil,
      [],
      [],
      subproject.description
    )
    tjTasks.push(topTask)
    # Getting all tasks and subtasks for subproject
    Issue.visible.where(subproject.project_condition(true)).find_each do |issue|
      # Add condition for use only activated issues
      unless issue.parent
        tjTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
          "[red#{issue.id}] " + issue.subject,
          topTask,
          child_task(issue, project),
          [],
          issue.description
        )

        redID = issue.id
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
		    if issue_depend.parent
          	      parent_task(issue_depend.parent, project)
		    else 
		      parent_depend(issue_depend, project)
		    end, 
          	    child_task(issue_depend, project),
          	    [], 
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

	if issue.tj_scheduled == true # fixed dates
	  tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
          )
        elsif issue.tj_allocates.to_s.length != 0
          if start_point.toTJP == ""
	    unless issue.children.to_s == "[]"
	       tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	              RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                      RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                      [],
	              RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	              RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                    )
	    else
	       tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	              RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                      RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                      RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
	              RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	              RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                    )
	    end
	  else

	    tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
              # TODO: Better determine start
              start_point,
              RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
              RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
	      RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	      RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
            )
	  end    
        elsif issue.start_date? and issue.due_date?
          tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            # TODO: Revisit TimePoint Null and TimePoint
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
          )
        end
	if issue.tj_activated == true
          topTask.children.push(tjTask)
	end
      end
    end
    tjSubprj.push(topTask)
    }
    return tjSubprj
  end

  # Method using if chosen only one project (subproject)
  def project_to_taskjuggler_task(project)
    tjTasks = []
    topTask = RedmineTaskjuggler::Taskjuggler::Task.new(project.identifier.gsub(/-/,"_"),
                project.name,
		nil,
                [],
                [],
                project.description
              )
    # Getting all tasks and subtasks for project
    Issue.visible.where(project.project_condition(true)).find_each do |issue|
      # Add condition for use only activated issues
      unless issue.parent
        tjTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
          "[red#{issue.id}] " + issue.subject,
          topTask,
          child_task(issue, project),
          [],
          issue.description
        )

        redID = issue.id
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
	 	    if issue_depend.parent
          	      parent_task(issue_depend.parent, project)
		    else topTask
		    end, 
          	    child_task(issue_depend, project),
          	    [], 
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


	if issue.tj_scheduled == true # fixed dates
	  tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
          )
        elsif issue.tj_allocates.to_s.length != 0
          if start_point.toTJP == ""
		   unless issue.children.to_s == "[]"
	              tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                        RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                        [],
	                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                      )
		    else
		      tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
	                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                        RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                        RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
	                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                      )
		    end
	  else
	    tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
              # TODO: Better determine start
              start_point,
              RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
              RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
	      RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
	     RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
          )
	  end    
        elsif issue.start_date? and issue.due_date?
          tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            # TODO: Revisit TimePoint Null and TimePoint
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
          )
        end
	if issue.tj_activated == true
        topTask.children.push(tjTask)
	end
      end
    end
    tjTasks.push(topTask)
    return tjTasks
  end

  # Method to display the subtasks
  def child_task(issue, project)
    tjTaskChildren = []
      if issue.children
	issue.children.each {|child|

	  tjTaskChild = RedmineTaskjuggler::Taskjuggler::Task.new('red' + child.id.to_s,
             "[red#{child.id}] " + child.subject,
             parent_task(child.parent, project),
             child_task(child, project),
             [],
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
			 if issue_depend.parent
          		   parent_task(issue_depend.parent, project)
			 else parent_depend(issue_depend, project)
			 end, 
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

	if child.tj_activated == true
	  tjTaskChildren.push(tjTaskChild)
	end
	}
      end
	
    return tjTaskChildren
    
  end

  # Method for determening the parent task
  def parent_task(issue_par, project)
      parentTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue_par.id.to_s,
          "[red#{issue_par.id}] " + issue_par.subject,
          if issue_par.parent
	    parent_task(issue_par.parent, project)
	  else 
	    parent_depend(issue_par, project)
	  end, 
	  [],
          [],
          issue_par.description
       )
  end

  # Method for determening project/subproject as the parent task for taks of this project/subproject
  def parent_depend(issue, project)
    if project.children.to_s == "[]"
       topTask = RedmineTaskjuggler::Taskjuggler::Task.new(project.identifier.gsub(/-/,"_"),
                  project.name,
	  	  nil,
                  [],
                  [],
                  project.description
                )

    else
      issue_id = issue.id
      subprojects = project.children
      subprojects.each {|subproject|
        Issue.visible.where(subproject.project_condition(true)).find_each do |issue|
          if issue_id == issue.id
            topTask = RedmineTaskjuggler::Taskjuggler::Task.new(subproject.identifier.gsub(/-/,"_"),
                      subproject.name,
	 	      nil,
                      [],
                      [],
                      subproject.description
                    )
          end
        end
      }
    end
    return topTask
  end

end
