# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/tjps_controller.rb

##
# Redmine Taskjuggler Tjps Controller
class TjpsController < ApplicationController
  unloadable
  # The line below I think is redoundant
  # helper Tjps_helper
  
  ##
  # Lists all Tjps
  def index
  end
  ##
  # Presents a form for adding a new Tjp
  # I can either ask the person to calculate a new file
  # or I can anticipate the creation on the new file.
  # I think this will be a preparatory screen with sanity checks
  # for the creation of a new TJP for this project
  def new
    @project = Project.find(params[:id])
    # Change a new object that represents what we are dealing with
    # Check to see that our project has all the necessary information in Redmine
    # Check to see that our project has all the necessary information in Taskjuggler
    # Show the results of the check to the user.
    # The end page should have
    # * the TJP variables in an edit form
    # * the issues with their vitals and a list next to them
    #   in a tree view
    # * the resources with a list and their vitals
    #   in a tree view
    # Warnings could be shown
  end
  ##
  # Inserts a new Tjp into the database
  def create
    # Initialize an empty TJP String that will be the return file
    # Charge the original Taskjuggeler representation of
    # The project
    # To TJP
    # The root Tasks
    # The root accounts
    # The root resources
    # The root reports
    # If there is an error, show that error and a back button
    # Otherwise Some kind of confirmation page is presented
  end
  ##
  # Shows the details of a Tjp
  # I suppose this could differ from HTML or TJP formats
  # A TJP format would be a downloadable page
  def show
  end
  ##
  # Presents a form for editing a Tjp
  # Editing could take different forms. It could be
  # a file, a text box, a recalculation on the server
  def edit
  end
  ##
  # Updates a Tjp in the database
  # If by file, I will just replace the TJP with the one I have here
  # If by text box, the contents of the text box will go here
  # If by recalculation, I will recalculate and update as pre create.
  def update
  end
  ##
  # Deletes a Tjp from the database
  # Straight-forward enough. Needs tjp_id
  def destroy
  end
end