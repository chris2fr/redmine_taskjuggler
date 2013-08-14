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
                      dailyworkinghours = 7.5, timingresolution = "45min")
        @id = id
        @name = name
        @version = version
        @period = period
        @now = tjNow
        @dailyworkinghours = dailyworkinghours
        @timingresolution = timingresolution
        
      end
      def toTJP
        tjpString = <<STRINGEND
project #{id} \"#{name}\" \"#{version}\" #{period}  {
      timeformat \"#{timeformat}\"
      currency \"#{currency}\"
      scenario plan \"Plan\"
      now #{now}
      numberformat \"#{numberformat}\"
      timingresolution #{timingresolution}
      dailyworkinghours #{dailyworkinghours}
}  
STRINGEND
        return tjpString
      end
    end
  end
end