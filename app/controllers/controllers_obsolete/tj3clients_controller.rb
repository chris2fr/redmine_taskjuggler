# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/tj3_clients_controller.rb

##
# Redmine Taskjuggler Tj3 Clients Controller
class Tj3ClientsController < ApplicationController
  unloadable
  # The line below I think is redoundant
  # helper Tj3ClientsHelper or tj3_clients_helper
  
  ##
  # Lists all Tj3Clients
  def index
    where = []
    if @project
      where = ["project_id = ?", params[:orders]]
    end
    @tj3_clients = Tj3Client.where(where)
  end
  ##
  # Presents a form for adding a new Tj3Client
  def new
    @project = params[:project]
  end
  ##
  # Inserts a new Tj3Client into the database
  def create
  end
  ##
  # Shows the details of a Tj3Client
  def show
  end
  ##
  # Presents a form for editing a Tj3Client
  def edit
  end
  ##
  # Updates a Tj3Client in the database
  def update
  end
  ##
  # Deletes a Tj3Client from the database
  def destroy
  end
end