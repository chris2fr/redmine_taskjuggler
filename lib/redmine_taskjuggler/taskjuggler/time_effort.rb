#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction module for TaskJuggler data model
  #
  module Taskjuggler
    ##
    # Models the timespan part of any task
    class TimeSpan
      attr_accessor :number,
        :units
      ##
      # Constructor Int , String
      def initialize (number, units)
        @number = number
        @units = units
      end
      ##
      def to_tjp
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
    ##
    # The start point of any TimeEffort
    class TimePointStart < TimePoint
      def to_tjp(level=0)
        " "*level+"start #{tjDateTime}\n"
      end
    end
    class TimePointEnd < TimePoint
      def to_tjp(level=0)
        " "*level+"end #{tjDateTime}\n"
      end
    end
    class TimePointDepends < TimePoint
      attr_accessor :depends
      def initialize depends
        @depends = depends
      end
      def empty?
        return false
      end
      def to_tjp(level=0)
        @level = level
        def i(s)
          s.gsub(/^/, ' '*@level) << "\n"
        end

        out = "depends "
        depArray = []
        @depends.each {|dep|
          depArray.push(dep.to_tjp(level))
        }
        out += depArray.join(", ")

        @level = @level - 2
        out << i("}")
        return out
      end
    end
    class Depend
      attr_accessor :task,
        :gap
      def initialize (task, gap)
        @task = task
        @gap = gap
      end
      def to_tjp(level=0)
        return " "*level+"#{@task.id} {#{@gap.to_tjp}}"
      end
    end
    class Gap
      attr_accessor :timeSpan,
        :type
      def initialize (timespan, type = "length")
        @timespan = timespan
        @type = type
      end
      def to_tjp
        return "gap#{@type} #{@timespan.to_tjp}"
      end
    end
    class GapLength
      def to_tjp
        "gaplength #{timeSpan.to_tjp}"
      end
    end
    class GapDuration
      def to_tjp
        "gapduration #{timeSpan.to_tjp}"
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
      def to_tjp
        "#{period}#{minMaxImum} #{timeSpan.to_tjp}"
      end
    end
    class TimePointNil
      def empty?
        return true
      end
      def to_tjp
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
    ##
    # The initial point of a TimeSpan (I think)
    class TimeEffortStartSpan < TimeEffort
      attr_accessor :timeSpan
      ##
      # Constructor TimePointStart , TimeSpan
      def initialize (timePointStart, timeSpan)
        super(timePointStart)
        @timeSpan = timeSpan
      end
      def to_tjp(level=0)
        out = timePointStart.to_tjp(level)
        out << " "*level << "duration" << timeSpan.to_tjp
        return out
      end
    end
    class TimeEffortStartStop < TimeEffort
      attr_accessor :timePointStop
      def initialize (timePointStart, timePointStop)
        @timePointStart = timePointStart
        @timePointStop = timePointStop
      end
      def to_tjp(level=0)
        out = timePointStart.to_tjp(level)
        out << timePointStop.to_tjp(level)
        return out
      end
    end
    class TimeEffortMilestone < TimeEffort
      def to_tjp(level=0)
        " "*level+"milestone"
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
      def to_tjp(level=0)
        @level = level
        def i(s)
          s.gsub(/^/, ' '*@level) << "\n"
        end
        out = ""
        if @timePointStart
          out << i(@timePointStart.to_tjp(@level))
        end
        #        out += "effort #{@timeSpan.to_tjp}\n#{@allocate.to_tjp}"
        #	puts 'debug timeSpan'
        #	puts @timeSpan.to_s
        if @timeSpan.empty?
          out << @allocate.to_tjp(@level) << "\n"
          out << @priority.to_tjp(@level) << "\n"
        else
          out << i("effort #{@timeSpan.to_tjp}")
          out << i("#{@allocate.to_tjp}")
          out << i("#{@priority.to_tjp}")
        end
        out << i("#{@tlimits.to_tjp}")
        return out
      end
    end
    class Allocate
      attr_accessor :resources, :attributes
      def initialize (resources, attributes = [])
        @resources = resources
        @attributes = attributes
      end
      def to_tjp(level=0)
        @level = level
        def i(s)
          s.gsub(/^/, ' '*@level) << "\n"
        end
        out = ""
        out << " "*level
        out << "allocate "
        out << @resources.join(", ").gsub(/\./,'_')
        out << " {" << @attributes.join(", ") << "}"
        return out
      end
    end

    # Add classes Priority and TaskLimits for Issue
    # priority and limits for issue (task) displayed in tjp-file
    class Priority
      attr_accessor :priority

      def initialize (priority)
        @priority = priority
      end
      def to_tjp(level=0)
        out = " "*level
        out = "priority " << @priority.join(" , ")
      end
    end

    class TaskLimits
      attr_accessor :tlimits

      def initialize (tlimits)
        @tlimits = tlimits
      end
      def to_tjp(level=0)
        out = " "*level
        out << "limits {" + @tlimits.join(" , ") + "}"
      end
    end
    ###

  end
end
