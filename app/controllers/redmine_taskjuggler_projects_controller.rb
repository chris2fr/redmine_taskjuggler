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
    @seen_issues = []
    @visited_issues = Hash.new

    # Task hierarchy TaskJuggler creation
    # issue: redmine issue instance
    # parent: taskjuggler task instance (built from project or issue)
    # returns taskjuggler task instance
    def redmine_issue_to_taskjuggler_task(issue, parent)
      # build up the task
      tj_task = RedmineTaskjuggler::Taskjuggler::Task.new(
        'T' + issue.id.to_s,
        "[T#{issue.id}] " + issue.subject,
        parent,
        [],
        [],
        issue.description,
        issue.tj_issue_etc
      )

      # FIXME: rework the huge conditional below!
      if issue.tj_scheduled
        tj_task.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
            RedmineTaskjuggler::Taskjuggler::TimePointStart.new(child.start_date),
            RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(child.due_date)
          )

      elsif issue.tj_allocates.empty?

        # resolve depends
        depends = IssueRelation.find(
          :all,
          :conditions => {:issue_to_id => 2,
                          :relation_type => [IssueRelation::TYPE_PRECEDES,
                                            IssueRelation::TYPE_BLOCKS]}
        ).each do |issue_from|
          @visited_issues[issue_from]
        end

        if depends.empty?
          start_point = RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
        else
          start_point = RedmineTaskjuggler::Taskjuggler::TimePointDepends.new(depends)
        end

        if start_point.empty?
          if issue.children.empty?
            tj_task.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
              )
          else
              tj_task.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
                RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                [],
                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
              )
          end
        else
          tj_task.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
            # TODO: Better determine start
            start_point,
            RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
            RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
            RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
            RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
          )
        end

      elsif issue.start_date? and issue.due_date?
        tj_task.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
          # TODO: Revisit TimePoint Null and TimePoint
          RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
          RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
        )
      end

      # recurse over children issues
      issue.children.each do |sub_issue|
        if sub_issue.tj_activated and not @seen_issues.include? sub_issue
          @seen_issues.push sub_issue
          task = redmine_issue_to_taskjuggler_task(sub_issue, issue)
          @visited_issues[sub_issue] = task
          tj_task.children.append task
        end
      end
      return tj_task
    end

    # Project hierarchy TaskJuggler creation
    # project: redmine project instance
    # parent: taskjuggler task instance (or nil)
    # returns taskjuggler task instance
    def redmine_project_to_taskjuggler_task(project, parent=nil)
      # build up the task
      tj_task = RedmineTaskjuggler::Taskjuggler::Task.new(
        project.identifier.gsub(/-/,"_"),
        project.name,
        parent,
        [],
        [],
        project.description
      )
      # recurse over children issues
      project.issues.each do |issue|
        unless @seen_issues.include? issue
          @seen_issues.push issue
          task = redmine_issue_to_taskjuggler_task(issue, tj_task)
          @visited_issues[issue] = task
          tj_task.children.push task
        end
      end
      # recurse over children projects
      project.children.each do |subproject|
        tj_task.children.push redmine_project_to_taskjuggler_task(subproject, tj_task)
      end
      return tj_task
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
                                                                       user.tj_limits,  # add limits, vacations and rate for Resource
                                                                       user.tj_vacations,  #
                                                                       user.tj_rate    #
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
    #tes = TimeEntry.all
    #puts "\n\n =======================================================\n\n"
    #puts Date.parse(@project.tj_period[0..9])..Date.parse(@project.tj_period[13..22])
    #puts 'spent_on ASC, user_id ASC'
    #puts tes
    #puts "\n\n =======================================================\n\n"
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

end
