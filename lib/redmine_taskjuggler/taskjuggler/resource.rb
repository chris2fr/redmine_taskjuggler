#encoding: utf-8

module RedmineTaskjuggler
  ##
  # Abstraction module for TaskJuggler data model
  module Taskjuggler
    ##
    # Represents a resource
    class Resource
      ##
      # An identifier following Taskjuggler constraints for identifiers
      attr_accessor :id
      ##
      # Resource (like a pointer)
      attr_accessor :parent
      ##
      # Array of Resource
      attr_accessor :children
      ##
      # Name of the resource , a colloquial String
      attr_accessor :name
      ##
      # String, Int, or Float (don't know) Showing the cost of this resource
      attr_accessor :rate
      ##
      # String (I think) Showing the working limits of this resource in TJ Syntax
      attr_accessor :limits
      ##
      # String (I think) representing the vacations of this resource
      attr_accessor :vacations
      ##
      # TjTeam to which is attached this resource
      attr_accessor :team
	# add limits, vacations and rate to the end...
      ##
      # Constructor Int, String, Taskjuggler::Resource , Array of Taskjuggler::Resource; TjTeam ,
      # String , String , String ? (notsure about that last one)
      def initialize (id, name, parent = nil, children = [], team = nil, limits = nil, vacations = nil, rate = nil)
        @id = id
        @name = name
	@limits = limits
	@vacations = vacations
	@rate = rate
	@parent = parent
        @children = children
        @team = team
      end
    end
    ##
    # Represents booked time for this resource
    class Booking
      attr_accessor :resource,
        :task,
        :periods
      ##
      # Constructor
      def initialize (resource_id, task_id, periods)
        @resource = resource
        @task = task
        @periods = periods
      end
    end
  end
end
