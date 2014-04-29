# encoding: utf-8
require_dependency 'redmine_taskjuggler'
#
# Redmine Taskjuggler Projects controller
#
class RedmineTaskjugglerProjectsController < ApplicationController
  unloadable
  
  before_filter :edit, :only => [:tjp_to_server, :tjp_save]
  ##
  # Not yet implemented, I did have a screen with a listing of projects
  def index
  end
  
  ##
  # Not yet implemented
  def new
  end
  
  ##
  # Not yet implemented
  def create
  end

  ##
  # This is the main page for any given project. The parameter comes by way of query string, strangely enough.
  def show # from tjindex
    @project = Project.find(params[:id])
    
    @redmine_taskjuggler_project = RedmineTaskjugglerProjects.where("project_id = ?", @project.id).first
    if not @redmine_taskjuggler_project
      @redmine_taskjuggler_project = RedmineTaskjugglerProjects.new()
      @redmine_taskjuggler_project.project_id = @project.id
      @redmine_taskjuggler_project.save
    end
  end
  ##
  # This is a TJP download
  # Note : the way this is programmed, only full hours can be used
  def edit # tjp
    ##
    # Project hierarchy TaskJuggler creation
    def redmine_project_to_taskjuggler_task(project)
      if project.children.to_s == "[]"
	 topTask = project_to_taskjuggler_task(project) # if we choose only one subproject (project)
      else
	topTask = subproject_to_taskjuggler_task(project) # if we choose main project (all subprojects/all tasks)       
      end
    end
   
    @project = Project.find(params[:id])
    @redmine_taskjuggler_project = RedmineTaskjugglerProjects.where("project_id = ?", @project.id).first
    
    tjProject = RedmineTaskjuggler::Taskjuggler::Project.new(@project.identifier.gsub("-","_"),
        @project.to_s,
        @project.tj_period.to_s,
        @project.tj_now.to_s,
        @project.tj_version.to_s,
        @project.tj_dailyworkinghours.to_s,
        @project.tj_timingresolution.to_s
        )
    tjResources = []
    User.where(tj_activated: true).order(:tj_team_id).find_each do |user|
      if user.login.to_s != ""
        team_name = "default_team"
        if user.tj_team_id and user.tj_team_id.to_i > 0
          team_name = TjTeam.find(user.tj_team_id).name.downcase.gsub(" ","_").gsub("-","_")
        end
	# team = "team_" + (user.tj_team_id || "default").to_s
	tjResources.push(RedmineTaskjuggler::Taskjuggler::Resource.new(user.login.gsub(/-/,'_').gsub(/\./,'_'),
	  user.firstname + ' ' + user.lastname,
	  user.tj_parent,
	  [],                   # Was this always an empty array ?
	  team_name,
	  user.tj_limits,	# add limits, vacations and rate for Resource
	  user.tj_vacations,	#
	  user.tj_rate		#
	))
      end
    end
    
    #
    # Booking generation here
    # 
    tjBookings = []
    tjProjectName = @project.identifier.gsub("-","_")
    if not @project.tj_period
      raise "tj_period in Project needs to be specified."
    end
    ##
    # TODO better handle the tj_period
    tes = TimeEntry.where(spent_on: (Date.parse(@project.tj_period[0..9])+0)..Date.parse(@project.tj_period[13..22])).order('spent_on ASC, user_id ASC')
    iUserId = nil
    iUserLogin = nil
    iIssueId = nil
    iDay = nil
    iHour = 10 # I start each day arbitrarily at 10:00
    iPeriods = []
    # Use a today object with a date and a start time
    # For each Time Entry
    tes.each do |te|
      # If we are on a new day or a new user, we need to reset the clock
      if iDay != te.spent_on or iUserId != te.user_id
        iHour = 10.0
	iDay = te.spent_on
      end
      # If we are on a new user or a new task, we need a new booking
      if iUserId != te.user_id or iIssueId != te.issue_id
	if iDay != nil # Check for first run through loop
	  tjBookings.append( # set task and resource ids on previous run
            RedmineTaskjuggler::Taskjuggler::Booking.new(
              tjProjectName + ".red" + te.issue_id.to_s,
              te.user.login,
              iPeriods
            )
          )
	end
	iUserId = te.user_id
	iPeriods = []
      end
      
      # Create a period from the current date and start time and for the duration.
      iPeriods.push(
        RedmineTaskjuggler::Taskjuggler::Period.new(
          sprintf("%s-%02d:%02d",
            te.spent_on.to_s,
            iHour.to_i,
            ((iHour - iHour.to_i) * 60).to_i
          ),
          te.hours
        )
      )
      iHour = iHour + te.hours # increment the task hour
      iIssueId = te.issue_id # actually only for the last iteration
      iUserLogin = te.user.login # actually only for the last iteration
    end
    if iDay != nil
      tjBookings.append(
        RedmineTaskjuggler::Taskjuggler::Booking.new(
          tjProjectName + ".red" + iIssueId.to_s,
          iUserLogin,
          iPeriods))
    end
    topTask = redmine_project_to_taskjuggler_task(@project)
 
    @tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,topTask,[],tjBookings) 

#    send_data @tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + ".tjp", :type => 'text/plain', :x_sendfile => true
  end
  
  ##
  # This is a CSV upload
  def update # from CSV
    project = Project.find(params[:id])
    # Get the CSV File
    #puts params
    
    uploaded_io = params[:csvfile]
#    uploaded_io = params[:redmine_taskjuggler_projects][:csvfile]
    #if uploaded_io[0,19] != '"Id";"Start";"End"'
    #  raise l(:exception_not_csv_issue_update)
    #end
    @lines = []
    # Parse the CSV File line by line
  
    if uploaded_io    # Condition for updating csv from computer of from server
      data = uploaded_io.tempfile
    else
      path = Setting.plugin_redmine_taskjuggler["tjp_path"]
      name_f = "redmine_update_issues_csv_" + project.identifier + "_" + project.tj_version.to_s.gsub(/\./,"_")  + ".csv"
      data = "#{path}#{name_f}"
    end

    # Update Redmine with the dates and effort
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
  
  ##
  # Not yet implemented
  def destroy
  end

  ##
  # Save tjp-file to computer
  def tjp_save
    project = Project.find(params[:id])
    f_name = project.identifier + "-" + project.tj_version.to_s.gsub(/\./,"_")  + ".tjp"
    data = @tjp.to_s
    send_data data, :filename => f_name, :type => 'text/plain', :x_sendfile => true
  end

  ##
  # Save tjp-file to server
  def tjp_to_server
    project = Project.find(params[:id])
    f_name = project.identifier + "-" + project.tj_version.to_s.gsub(/\./,"_")  + ".tjp"
    data = @tjp.to_s
    Dir.chdir Setting.plugin_redmine_taskjuggler["tjp_path"]
    File.write(f_name, data)
    redirect_to :back
  end

  ##
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
          issue.description,
          issue.tj_issue_etc
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
          	    issue_depend.description,
          	    issue_depend.tj_issue_etc
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
  
  ##
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
          issue.description,
          issue.tj_issue_etc
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
          	    issue_depend.description,
          	    issue_depend.tj_issue_etc
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

  ##
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
             child.description,
             child.tj_issue_etc
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
          		 issue_depend.description,
          		 issue_depend.tj_issue_etc
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

  ##
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
          issue_par.description,
          issue_par.tj_issue_etc
       )
  end

  ##
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
        Issue.visible.where(subproject.project_condition(true)).find_each do |inner_issue|
          if issue_id == inner_issue.id
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
