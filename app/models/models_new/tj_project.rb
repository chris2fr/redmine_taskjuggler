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
  has_many :tj_extend_resources
  ##
  # tjp_part_project_extend
  has_many :tj_extend_tasks
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
  # Leaves
  has_many :tj_leaves
  ##
  # project_id
  attr_accessible :code
  ##
  # project_name 
  attr_accessible :name
  ##
  # project_version 
  attr_accessible :version
  ##
  # start and end dates
  attr_accessible :interval
  ##
  # currency USD
  attr_accessible :currency
  ##
  # rate some float amount of currency
  attr_accessible :rate
  ##
  # number format : "-" "" "," "." 1
  attr_accessible :numberformat
  ##
  # time format %Y-%m-%d
  attr_accessible :timeformat
  ##
  # timezone Europe/Paris
  attr_accessible :timezone
  ##
  # now 2001-09-11-13:00
  attr_accessible :now
  ##
  # Currency format "(" ")" "," "." 0
  attr_accessor :currencyformat
  
  ##
  # A hashtable representation for the template
  def to_hashtable
    result = {
      code: code,
      name: name,
      version: version,
      interval: interval,
      timezone: timezone,
      timeformat: timeformat,
      currencyformat: currencyformat,
      currency: currency,
      now: now,
      extend_resources: "",
      extend_tasks: "",
      numberformat: numberformat,
      scenarios: scenarios,
      leaves: "leaves ",
      flags: "flags ",
      macros: "",
      accounts: "",
      accountbalance: "",
      resources: "",
      tasks: "",
      bookings: "",
      reports: ""
    }
    ##
    # We need at least two top accounts
    if @accounts.length > 1
      @accounts.each { | account |
        result[:accounts] += account.to_s
      }
      result[:accountbalance] = "balance " + account[0].code.to_s + " " + account[1].code.to_s
    end
    comma = ""
    @leaves.each { | leave |
      result[:leaves] += comma + leave.to_s
      comma = ",\n  "
    }
    comma = ""
    @flags.each { | flag |
      result[:flags] += comma + leave.to_s
      comma = ",\n  "
    }
    @macros.each { | macro |
      result[:flags] += macro.to_s + '\n'
    }
    @resources.each { | resource |
      result[:resources] += resource.to_s + '\n'
    }
    @root_tasks.each { | task |
      result[:tasks] += task.to_s + '\n'
    }
    @bookings.each { | booking |
      result[:bookings] += booking.to_s + '\n'
    }
    @reports.each { | report |
      result[:reports] += report.to_s + '\n'
    }
  end
  def to_s
    template % to_hashtable 
  end
end