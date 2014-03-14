module RedmineTaskjuggler
  #
  # Abstraction module for TaskJuggler data model
  #
  module Taskjuggler
    class Resource
      attr_accessor :id,
        :parent,
        :children,
        :name,
        :rate,
        :limits,
	:vacations
	# add limits, vacations and rate
      def initialize (id, name, limits, vacations, rate, parent = nil, children = [])
        @id = id
        @name = name
	@limits = limits
	@vacations = vacations
	@rate = rate
	@parent = parent
        @children = children
      end
    end
    class Booking
      attr_accessor :resource,
        :task,
        :periods
      def initialize (resource_id, task_id, periods)
        @resource = resource
        @task = task
        @periods = periods
      end
    end
  end
end
