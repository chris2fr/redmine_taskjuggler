# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# ActiveRectord Tj3. One such record is created for every
# command-line tj3 execution we run.
class TjpPart < ActiveRecord::Base
  unloadable
  ##
  # A hashtable of variables that will be replaced in the content
  attr_accessible :variables
  ##
  # The a varible for the showing of the content
  attr_writer :template
  ##
  # Accessing the template
  def template
    @template ||=""
    @template
  end
  def to_s
    template % {@content}
  end
end

class TjpFile < TjpPart
  ##
  # tjp_part_top
  has_one :tjp_part_top, :class_name => "TjpPart", :foreign_key => "tjp_part_top"
  ##
  # tjp_part_project
  has_one :tjp_part_project, :class_name => "TjpPart", :foreign_key => "tjp_part_project"
  ##
  # tjp_part_flags
  has_one :tjp_part_flags, :class_name => "TjpPart", :foreign_key => "tjp_part_flags"
  ##
  # tjp_part_global
  has_one :tjp_part_global, :class_name => "TjpPart", :foreign_key => "tjp_part_global"
  ##
  # tjp_part_macros
  has_one :tjp_part_macros, :class_name => "TjpPart",:foreign_key => "tjp_part_macros"
  ##
  # tjp_part_accounts
  has_one :tjp_part_accounts, :class_name => "TjpPart", :foreign_key => "tjp_part_accounts"
  ##
  # tjp_part_resources
  has_one :tjp_part_resources, :class_name => "TjpPart", :foreign_key => "tjp_part_resources"
  ##
  # tjp_part_tasks
  has_one :tjp_part_tasks, :class_name => "TjpPart", :foreign_key => "tjp_part_tasks"
  ##
  # tjp_part_bookings
  has_one :tjp_part_bookings, :class_name => "TjpPart", :foreign_key => "tjp_part_bookings"
  ##
  # tjp_part_reports
  has_one :tjp_part_reports, :class_name => "TjpPart", :foreign_key => "tjp_part_reports"
  ##
  # tjp_part_bottom
  has_one :tjp_part_bottom, :class_name => "TjpPart", :foreign_key => "tjp_part_bottom"
  ##
  # The default template for the TJP Project
  def template
    @template ||= <<-EOS
    %{tjp_part_top}
    %{tjp_part_project}
    %{tjp_part_flags}
    %{tjp_part_global}
    %{tjp_part_macros}
    %{tjp_part_accounts}
    %{tjp_part_resources}
    %{tjp_part_tasks}
    %{tjp_part_bookings}
    %{tjp_part_reports}
    %{tjp_part_bottom}
    EOS
    @template
  end
end

##
# TJ Include Files
class TjiFile < TjpPart

  ##
  # filename
  attr_accessible :filename
  ##
  # Subdirectory relative to the TJP file or execution
  attr_accessible :directory

end


##
# The project declaration in the TJP file
class TjpPartProject < TjiFile
  ##
  # tjp_part_project_scenario
  has_one :tjp_part_project_scenario, :class_name => "TjpPart",
  :foreign_key => "tjp_part_project_scenario"
  ##
  # tjp_part_project_extend
  has_one :tjp_part_project_extend, :class_name => "TjpPart",
  :foreign_key => "tjp_part_project_extend"
  ##
  # Includes toward the end of the project declaration if admissible (actually, I think not)
  has_many :tji_files
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
  ##
  # The default template for the TJP Project
  def template
    @template ||= <<-EOS
      project %{project_id} "%{project_name}" "%{project_version}" %{start_date} - %{end_date} {
        %{tjp_project_to_s}
      }
      dailyworkinghours  %{dailyworkinghours}
      currency "%{currency}"
      now %{now}
      
      %{tjp_part_project_extend}
      %{tji_files_expantded}
      }
    EOS
    @template
  end
end