require_dependency 'project' 
#
# Redmine Taskjuggler main controller
#
class RedmineTaskjugglerController < ApplicationController
  unloadable
  
  # This is the index and only visible specific view
  def index
    @project = Project.find(params[:id])
    
  end
  
  # This is a TJP download
  def tjp
    @project = Project.find(:params[:id])
  end
  
  # This is a CSV upload
  def csv
    # Get the CSV File
    # Parse the CSV File line by line
    # Update Redmine with the dates and effort
  end
end