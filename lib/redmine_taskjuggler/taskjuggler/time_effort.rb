module RedmineTaskjuggler
  #
  # Abstraction module for TaskJuggler data model
  #
  module Taskjuggler
    #
    # Models the timespan part of any task
    #
    class TimeSpan
      attr_accessor :number,
        :units
      def initialize (number, units)
        @number = number
        @units = units
      end
      def toTJP
        "#{number}#{units}"
      end
    end
    #
    # Models the yyyy-mm-dd{-hh:mm} in TaskJuggler
    #
    class TimePoint
      attr_accessor :tjDateTime
      def initialize tjDateTime
        @tjDateTime = tjDateTime
      end
    end
    class TimePointStart < TimePoint   
      def toTJP
        "start #{tjDateTime}"
      end
    end
    class TimePointEnd < TimePoint
      def toTJP
        "end #{tjDateTime}"
      end
    end
    class TimePointDepends < TimePoint
      attr_accessor :depends
      def initialize depends
        @depends = depends
      end
      def toTJP
        tjpString = "depends "
        depArray = []
        @depends.each {|dep|
          depArray.push(dep.toTJP)
        }
        tjpString += depArray.join(", ")
        return tjpString
      end
    end
    class Depend
      attr_accessor :task,
        :gap
      def initialize (task, gap)
        @task = task
        @gap = gap
      end
      def toTJP
        return "#{@task.id} {#{@gap.toTJP}}"
      end
    end
    class Gap
      attr_accessor :timeSpan,
       :type
      def initialize (timespan, type = "length")
        @timespan = timespan
        @type = type
      end
      def toTJP
        return "gap#{@type} #{@timespan.toTJP}"
      end
    end
    class GapLength
      def toTJP
        "gaplength #{timeSpan.toTJP}"
      end
    end
    class GapDuration
      def toTJP
        "gapduration #{timeSpan.toTJP}"
      end
    end
    class Limit
      attr_accessor :period, # min, max, daily, weekly, monthly
        :minMaxImum, # min, max, imum
        :timeSpan
      def initialize (period, minMaxImum, timeSpan)
        @period = period
        @minMaxImum = minMaxImum
        @timeSpan = timeSpan
      end
      def toTJP
        "#{period}#{minMaxImum} #{timeSpan.toTJP}"
      end
    end
    class TimePointNil
      def toTJP
        ""
      end
      def initialize
      end
    end
    class TimeEffort
      attr_accessor :timePointStart
      def initialize (timePointStart)
        @timePointStart = timePointStart
      end
    end
    class TimeEffortStartSpan < TimeEffort
      attr_accessor :timeSpan
      def initialize (timePointStart, timeSpan)
        super(timePointStart)
        @timeSpan = timeSpan
      end
      def toTJP
        "#{timePointStart.toTJP}\nduration #{timeSpan.toTJP}"
      end
    end
    class TimeEffortStartStop < TimeEffort
      attr_accessor :timePointStop
      def initialize (timePointStart, timePointStop)
        @timePointStart = timePointStart
        @timePointStop = timePointStop
      end
      def toTJP
        "#{timePointStart.toTJP}\n#{timePointStop.toTJP}"
      end
    end
    class TimeEffortMilestone < TimeEffort
      def toTJP
        "milestone"
      end
      def initialize (timePointStart)
        super.initialize(timePointStart)
      end
    end
    class TimeEffortEffort < TimeEffort
      attr_accessor :timeSpan,
        :allocate
        :priority
	:tlimits
      def initialize (timePointStart, allocate, timeSpan = [], priority, tlimits)
        #super.initialize(timePointStart) # For some reason, it passes three arguments
        @timePointStart = timePointStart
        @allocate = allocate
        @timeSpan = timeSpan
        @priority = priority
	@tlimits = tlimits
      end
      def toTJP
        tjpString = @timePointStart.toTJP
        if tjpString != "" and tjpString != nil
          tjpString += "\n"
        end
#        tjpString += "effort #{@timeSpan.toTJP}\n#{@allocate.toTJP}"
#	puts 'debug timeSpan'
#	puts @timeSpan.to_s
	if @timeSpan == []
	  tjpString += "#{@allocate.toTJP}\n#{@priority.toTJP}\n"
	else
	  tjpString += "effort #{@timeSpan.toTJP}\n#{@allocate.toTJP}\n#{@priority.toTJP}\n"
	end
	tjpString += "#{@tlimits.toTJP}"
        return tjpString
      end
    end
    class Allocate
      attr_accessor :resources,
        :attributes
      def initialize (resources, attributes = [])
        @resources = resources
        @attributes = attributes
      end
      def toTJP
        tjpString = "allocate "
        tjpString += @resources.join(", ")
        tjpString += " {"  + @attributes.join(", ") + "}"
        return tjpString
      end
    end

    # Add classes Priority and TaskLimits for Issue
    # priority and limits for issue (task) displayed in tjp-file
    class Priority
      attr_accessor :priority

      def initialize (priority)
	@priority = priority
      end
      def toTJP
	tjpString = "priority "
	tjpString += @priority.join(" , ")
      end
    end

    class TaskLimits
      attr_accessor :tlimits

      def initialize (tlimits)
	@tlimits = tlimits
      end
      def toTJP
	tjpString = "limits "
	tjpString += "{" + @tlimits.join(" , ") + "}"
      end
    end
    ###

  end
end
