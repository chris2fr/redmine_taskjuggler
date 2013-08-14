#
# Redmine Taskjuggler main controller
#
class RedmineTaskjugglerController < ApplicationController
  unloadable

  def export
  end
  
  def hello
  end
  
  def initial_export
  end

  def import
  end
  
  def admin 
  end

  #
  # Pick one RedTaskProject to show
  #
  def index
    @rmtjProjects = RedTaskProject.all
    @projects = Project.where("parent_id IS NOT NULL").find_by(status: 1).order("parent_id","name")
      # :conditions => ["status = 1 AND parent_id IS NOT NULL"],
      # :order => ["parent_id, name"] )
    @users = User.find(:all)
  end

  #
  # Shows one RedTaskProject control panel
  #
  def show project_id
    #code
  end
  #
  # This method exports a TaskJuggler project file with tasks without bookings.
  #
  def exportTaskjuggeler project_id
    #code 
  end
  #
  # This method exports the bookings for a TaskjugglerProject file
  #
  def exportTaskjugglerBookings project_id
    #code
  end
  #
  # This method updates in Redmine dates from a CSV file, probably from TaskJuggler
  #
  def importDates csv_file_path
    #code
  end


  def PutIssuesByCat (issues)
    retvar = {}
    issues.each do |issue|
      if issue.category and issue.category.name
        cat_name = issue.category.name
      else
        cat_name = "no_category"
      end
      if not retvar[cat_name]
        retvar[cat_name] = []
      end
      retvar[cat_name].push(issue)
    end
    return retvar
  end

end