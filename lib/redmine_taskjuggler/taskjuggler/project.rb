module RedmineTaskjuggler
  #
  # Abstraction module for TaskJuggler data model
  #
  module Taskjuggler
    #
    # Models a Taskjuggler Project : the heading part of a TJP File
    #
    class Project
      attr_accessor :id,
        :name,
        :version,
        :dailyworkinghours,
        :period,
        :currency,
        # :scenarios, # {"plan" => {}}
        :now,
        :numberformat,
        :timingresolution,
        :timeformat
      #
      # Initializes the project with base information
      #
      def initialize (id, name, period, tjNow, \
                      version = "0.0.0", \
                      dailyworkinghours = 7.5, timingresolution = "15min")
        @id = id
        @name = name
        @version = version
        @period = period
        @now = tjNow
        @dailyworkinghours = dailyworkinghours
        @timingresolution = timingresolution
        
      end
      def toTJP
        tjpString = "project #{id} \"#{name}\" \"#{version}\" #{period}  {\n"
        {'timeformat' => timeformat,
         'currency' => currency
         }.each do |k,v|
          if v and v != ""
            tjpString += "  " + k.to_s + " \"" + v + "\"\n"
          end
        end
        {'timingresolution' => timingresolution,
         'dailyworkinghours' => dailyworkinghours}.each do |k,v|
          if v and v != ""
            tjpString += "  " + k.to_s + " " + v + "\n"
          end
        end
    
        tjpString += "  extend task {\n"
        tjpString += "    number Redmine 'Redmine'\n" 
        tjpString += "  }\n"
        tjpString += "  now #{now}\n"
        tjpString += "}\n"

        return tjpString
      end
    end
  end
end