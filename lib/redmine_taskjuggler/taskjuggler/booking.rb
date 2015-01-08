#encoding: utf-8

module RedmineTaskjuggler
  module Taskjuggler
    ##
    # Represents a series of periods that a Resource is dedicated to a Task
    class Booking
      ##
      # The string of caracters between periods such as <code>, </code>
      PERIOD_STRING_SEP = ", \n  "
      ##
      # link to the +task_id+ of the attached Task of the Booking
      attr_accessor :task_id
      ##
      # link to the +resource_id+ of the attached Resource of the Booking
      attr_accessor :resource_id
      ##
      # link to the +periods+ Period of the Booking
      attr_accessor :periods
      ##
      # Constructor with the +task_id+, the +resource_id+, and the +periods+
      # of the booking.
      def initialize (task_id, resource_id, periods)
        @task_id = task_id
        @resource_id = resource_id
        @periods = periods
      end
      ##
      # Returns a string TJP representation of the booking
      def to_s
        booking_string = "supplement task %s {\n  booking %s %s {overtime 1}\n}"
        periods_tjp = ""
        @periods.each do |p|
          periods_tjp += p.to_s + PERIOD_STRING_SEP
        end
        if periods_tjp.length > PERIOD_STRING_SEP.length
          periods_tjp = periods_tjp[0,periods_tjp.length - PERIOD_STRING_SEP.length]
          sprintf(booking_string,@task_id,@resource_id, periods_tjp)
        else
          ""
        end
      end
    end
    ##
    # Represents a period of time on a task in one date from a time entry
    # mainly used by Booking.
    class Period
      ##
      # The start date and time 2021-12-31-16:00
      attr_accessor :tjDateTimeStart
      ##
      # int, the number of hours of the booking
      attr_accessor :tjDuration
      ##
      # Returns a string TJP representation of the period such as
      # <code>2021-12-31-16:00 +2h</code>
      # TODO, adjust start time of day
      def to_s ()
        tjpString = tjDateTimeStart.to_s + " +" + tjDuration.to_s + "h"
        tjpString
      end
      ##
      # Construction with a +tjDateTimeStart+ and a +tjDuration+
      def initialize (tjDateTimeStart, tjDuration)
        @tjDateTimeStart = tjDateTimeStart
        @tjDuration = tjDuration
      end
    end
  end
end
