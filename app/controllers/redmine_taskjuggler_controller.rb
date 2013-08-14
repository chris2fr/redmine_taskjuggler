require_dependency 'redmine_taskjuggler/taskjuggler'
require_dependency 'redmine_taskjuggler/redmine' 
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
    #tjp = RedmineTaskjuggler::TJP.new()
    send_data "project ...", :filename => @project.identifier + "-" + @project.tj_version.to_s.sub(".","_") + ".tjp", :type => 'text/plain'
  end
  
  # This is a CSV upload
  def csv
    # Get the CSV File
    # Parse the CSV File line by line
    # Update Redmine with the dates and effort
  end
end