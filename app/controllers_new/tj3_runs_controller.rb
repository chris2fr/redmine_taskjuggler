# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/tj3_runs_controller.rb

##
# Redmine Taskjuggler Tj3Runs Controller
class Tj3RunsController < ApplicationController
  unloadable
  ##
  # Lists all Tj3Runs for this project
  # A run can be anywhere or on the server
  # A run can be tj3 alone or tj3client
  def index
    @tj3_runs = Tj3Run.where(@project ? ["project_id = ?", project_id] : [])
  end
  ##
  # Presents a form for adding a new Tj3Run
  def new
  end
  ##
  # Inserts a new Tj3Run into the database
  def create
  end
  ##
  # Shows the details of a Tj3Run
  def show
  end
  ##
  # Presents a form for editing a Tj3Run
  def edit
  end
  ##
  # Updates a Tj3Run in the database
  def update
  end
  ##
  # Deletes a Tj3Run from the database
  def destroy
  end
end