# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/bookings_controller.rb

##
# Redmine Taskjuggler Bookings Controller
class BookingsController < ApplicationController
  unloadable
  # The line below I think is redoundant
  # helper Bookings_helper
  
  ##
  # Lists all Bookings
  # Can have filters by user and/or by task and/or by project
  # Should be either Issue or Project and not both
  def index
  end
  ##
  # Presents a form for adding a new Booking
  # Can have String date, Int issue_id, int user_id
  def new
  end
  ##
  # Inserts a new Booking into the database
  # Must have String date, Int issue_id, int user_id, number of hours
  def create
  end
  ##
  # Shows the details of a Booking
  # I guess can have a booking_id, but it is more meaningful to show
  # multiple bookings together. Otherwise, this is just a copy of TimeEntry
  def show
  end
  ##
  # Presents a form for editing a Booking
  # Again, it is more meaningful to present multiple edits at once for
  # rather than an issue on a date, but multiple dates on an issue,
  # multiple issues on a date, or both. Input booking_id, or date_range
  # or issue_id
  def edit
  end
  ##
  # Updates a Booking in the database
  # Should take a hashtable where each entry is int issue_id, int user_id,
  # int booking_id, int hours, string date
  def update
  end
  ##
  # Deletes a Booking from the database
  # booking_id would suffice
  def destroy
  end
end