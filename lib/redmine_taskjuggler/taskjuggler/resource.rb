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

      # Constructor Int, String, Taskjuggler::Resource , Array of Taskjuggler::Resource; String (from TjTeam) ,
      # String , String , String ? (notsure about that last one)
      def to_tjp(level=0)
        @level = level
        def i(s)
          s.gsub(/^/, ' '*@level) << "\n"
        end

        out = i("resource #{@id} \"#{@name}\" {")
        @level = @level + 2
        if @children and not @children.empty?
          @children.each do |child|
            out << child.to_tjp(@level)
          end
        end

        # limits, vacation and rate displayed in tjp-file
        if @limits
          out << i("limits " + "{" + "#{@limits.join(' ')}" + "}")
        end
        if @vacantions and not @vacations.empty?
          out << i("#{@vacations}" + "")
        end
        if @rate
          out << i("rate " + "#{@rate}" + "")
        end

        @level = @level - 2
        out << i("}")
        return out
      end
    end
    class UserResource < Resource
      def initialize (user, team = nil)
        @id = user.login.gsub(/-/,'_').gsub(/\./,'_')
        @name = user.firstname << " " << user.lastname
        @limits = user.tj_limits
        @vacations = user.tj_vacations
        @rate = user.tj_rate
        @parent = user.tj_parent # XXX ??
        @children = []
        @team = team
        if team
          team.children.push self
        end
      end
    end
    class TeamResource < Resource
      def initialize (team = nil)
        if not team
          @id = "default_team"
          @name = "Default Team"
        else
          @id = team.id
          @name = team.name
        end
        @limits = nil
        @vacations = vacations
        @rate = rate
        @parent = parent
        @children = []
        @team = nil
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
      def to_tjp(level=0)
        @level = level
        def i(s)
          s.gsub(/^/, ' '*@level) << "\n"
        end
        #
        out << i("booking #{@resource.to_s} #{
          periods.each{|p| p.to_s}.join(", ")
        }")
      end
    end
  end
end
