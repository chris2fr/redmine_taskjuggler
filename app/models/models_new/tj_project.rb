# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_project.rb
##
# The project declaration in the TJP file
class TjProject < ActiveRecord::Base
  ##
  # tjp_part_project_scenario
  has_one :tj_scenario
  ##
  # tjp_part_project_extend
  has_many :tj_extends
  ##
  # Flags
  has_many :tj_flags
  ##
  # Accounts
  has_many :tj_accounts
  ##
  # Resources
  has_many :tj_resources
  ##
  # Root Tasks from Projects
  has_many :tj_root_tasks
  ##
  # Bookings
  has_many :tj_bookings
  ##
  # Report Macros
  has_many :tj_report_macros
  ##
  # Reports
  has_many :tj_reports
  ##
  # project_id
  attr_accessible :project_id
  ##
  # project_name 
  attr_accessible :project_name
  ##
  # project_version 
  attr_accessible :project_version
  ##
  # start_date 
  attr_accessible :start_date
  ##
  # end_date 
  attr_accessible :end_date
  ##
  # currency 
  attr_accessible :currency
  ##
  # number_format 
  attr_accessible :number_format
  ##
  # time_format 
  attr_accessible :time_format
  ##
  # now 
  attr_accessible :now