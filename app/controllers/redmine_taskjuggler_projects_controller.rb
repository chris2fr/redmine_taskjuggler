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

  # Generates and download the tjp file
  # * returns tjp file
  def edit
    ##
    @seen_issues = []
    @visited_issues = Hash.new

    # Task hierarchy TaskJuggler creation
    # * +issue+ redmine issue instance
    # * +parent+ taskjuggler task instance (built from project or issue)
    # * returns +taskjuggler task instance+
    def redmine_issue_to_taskjuggler_task(issue, parent)
      # build up the task
      tj_task = RedmineTaskjuggler::Taskjuggler::Task::FromIssue.new(issue, parent)

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
    # * +project+ redmine project instance
    # * +parent+ taskjuggler task instance (or nil)
    # * returns +taskjuggler task instance+
    def redmine_project_to_taskjuggler_task(project, parent=nil)
      # build up the task
      tj_task = RedmineTaskjuggler::Taskjuggler::Task::FromProject.new(project, parent)
      # recurse over children issues
      project.issues.each do |issue|
        if issue.tj_activated and not @seen_issues.include? issue
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

    # Build resources
    # * returns +resource list+
    def redmine_user_to_taskjuggler_resource()
      # resource cache
      tj_resources = Hash.new

      # find all users with no team
      no_team_users = User.where(tj_activated: true, tj_team_id: nil).all()
      unless no_team_users.empty?
        # create new team
        tj_team = RedmineTaskjuggler::Taskjuggler::TeamResource.new()
        # cache that
        tj_resources[tj_team.name] = tj_team
        # for each user, assign it to the teams
        no_team_users.each do |user|
          unless user.login.empty?
            RedmineTaskjuggler::Taskjuggler::UserResource.new(
              user,
              tj_team
            )
          end
        end
      end

      # find all users with teams
      TjTeam.all().each do |team|
        # if team is cached get it
        if tj_resources.has_key? team.name
          tj_team = tj_resources[team.name]
        else # otherwise create new team
          tj_team = RedmineTaskjuggler::Taskjuggler::TeamResource.new(
            team.name.downcase.gsub(" ","_").gsub("-", "_")
          )
          tj_resources[tj_team.name] = tj_team
        end
        # add user to team
        User.where(tj_activated: true, tj_team_id: team.id).find_each do |user|
          RedmineTaskjuggler::Taskjuggler::UserResource.new(user, team)
        end
      end

      return tj_resources.values
    end

    # Build booking
    # XXX need improvements
    # * returns +taskjuggler booking instance list+
    def redmine_periods_to_taskjuggler_booking(project)
      # booking cache
      tj_booking = []

      tj_project_name = project.identifier.gsub("-","_")
      if not project.tj_period
        raise "tj_period in Project needs to be specified."
      end
      ##
      # TODO better handle the tj_period
      tes = TimeEntry.where(spent_on: (Date.parse(project.tj_period[0..9])+0)..Date.parse(project.tj_period[13..22])).order('spent_on ASC, user_id ASC')

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
            tj_booking.append(
              # set task and resource ids on previous run
              RedmineTaskjuggler::Taskjuggler::Booking.new(
                tj_project_name + ".T" + te.issue_id.to_s,
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
        tj_booking.append(
          RedmineTaskjuggler::Taskjuggler::Booking.new(
            tj_project_name + ".T" + iIssueId.to_s,
            iUserLogin,
            iPeriods
          )
        )
      end
      return tj_booking
    end

    project = Project.find(params[:id])

    @tjp = RedmineTaskjuggler::TJP.new(
      RedmineTaskjuggler::Taskjuggler::Project.new(project),
      redmine_user_to_taskjuggler_resource(),
      redmine_project_to_taskjuggler_task(project),
      [],
      redmine_periods_to_taskjuggler_booking(project)
    )
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
