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
        tjResources.push(RedmineTaskjuggler::Taskjuggler::Resource.new(user.login.gsub(/-/,'_'),
                  user.firstname + ' ' + user.lastname,
                  user.tj_parent))
    end
    tjTasks = []
    @project.issues.where(tj_activated: true).find_each do |issue|
      tjTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
        "[red#{issue.id}] " + issue.subject,
        tjProject.id,
        nil,
        [], #issue.tj_flags,
        issue.description
      )
      if issue.tj_allocates
        tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
          # TODO: Better determine start
          RedmineTaskjuggler::Taskjuggler::TimePointNil.new(),
          RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
          RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h')
        )
      elsif issue.tj_milestone
        tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortMilestone.new(
          # TODO: Revisit TimePoint Null and TimePoint
          # TODO: The format of start might not suffice as such
          issue.start || RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
        )
      elsif issue.start? and issue.end?
        tjTask.timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
          # TODO: Revisit TimePoint Null and TimePoint
          issue.start,
          issue.due_date
        )
      end
      tjTasks.push(tjTask)
    end
    tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,tjTasks)
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
    CSV.foreach(uploaded_io.tempfile, :headers => true, :col_sep => ';') {|csvline|
      issue = Issue.find(csvline["Redmine"])
      test = issue.update_attributes({'start_date' => csvline['Start'], 'due_date' => csvline['End']})
      @lines.push("#" + csvline["Redmine"].to_s + ". #{issue.subject} : #{issue.start_date} - #{issue.due_date} " + issue.errors.messages.inspect.to_s)
    }
    # Parse the CSV File line by line
    # Update Redmine with the dates and effort
  end
end