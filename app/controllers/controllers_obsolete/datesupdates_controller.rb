# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb

##
# Redmine Taskjuggler DatesUpdates Controller
class DatesUpdatesController < ApplicationController
  unloadable
  # The line below I think is redoundant
  # helper DatesUpdates_helper
  
  ##
  # Lists all DatesUpdates
  # Should be per project
  # A CVS represents a project calculation
  def index
  end
  ##
  # Presents a form for adding a new DatesUpdate
  # This can be by either loading the CSV to the server
  # or if there is a configuration for a server-based
  # calculation machine, then it would be a calculation on the server,
  # or if there is a Taskjuggler-as-a-service machine somewhere
  # then that will be used.
  def new
  end
  ##
  # Inserts a new DatesUpdate into the database
  def create
  end
  ##
  # Shows the details of a DatesUpdate
  def show
  end
  ##
  # Presents a form for editing a DatesUpdate
  def edit
  end
  ##
  # Updates a DatesUpdate in the database
  def update
  end
  ##
  # Deletes a DatesUpdate from the database
  def destroy
  end
end