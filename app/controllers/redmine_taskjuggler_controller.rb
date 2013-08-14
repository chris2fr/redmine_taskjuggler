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
      tjTasks.push(RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
        "[red#{issue.id}] " + issue.subject,
        tjProject.id,
        nil,
        [], #issue.tj_flags,
        issue.description
      ))
    end
    tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,tjTasks)
    #tjp = RedmineTaskjuggler::TJP.new()
    send_data tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + ".tjp", :type => 'text/plain'
  end
  
  # This is a CSV upload
  def csv
    # Get the CSV File
    # Parse the CSV File line by line
    # Update Redmine with the dates and effort
  end
end