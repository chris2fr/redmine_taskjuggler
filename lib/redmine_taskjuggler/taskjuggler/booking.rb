#encoding: utf-8

module RedmineTaskjuggler
  module Taskjuggler
    class Booking
      attr_accessor :task_id,
        :resource_id,
        :periods
      def initialize (task_id, resource_id, periods)
        @task_id = task_id
        @resource_id = resource_id
        @periods = periods
      end
    end
    class Period
      attr_accessor :tjDateTimeStart,
        :tjDuration
      def toTJP ()
        tjpString = tjDateTimeStart.to_s + " +" + tjDuration.to_s + "h"
        tjpString
      end
      def initialize (tjDateTimeStart, tjDuration)
        @tjDateTimeStart = tjDateTimeStart
        @tjDuration = tjDuration
        #puts "\n\n     NEW PERIOD\n\n"
      end
    end
  end
end
