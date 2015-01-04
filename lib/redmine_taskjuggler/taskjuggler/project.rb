#encoding: utf-8

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
    end
  end
end
