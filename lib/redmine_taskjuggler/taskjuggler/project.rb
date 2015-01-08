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
      def initialize (project)
        @id                = project.identifier.gsub("-","_")
        @name              = project.to_s
        @period            = project.tj_period.to_s
        @now               = project.tj_now.to_s
        @version           = project.tj_version.to_s
        @dailyworkinghours = project.tj_dailyworkinghours.to_s
        @timingresolution  = project.tj_timingresolution.to_s
      end
      def to_tjp(level=0)
        @level = level
        def i(s)
          s.gsub(/^/, ' '*@level) << "\n"
        end
        out = i("project %s \"%s\" \"%s\" %s {" % [@id,
                                                   @name,
                                                   @version,
                                                   @period])
        @level = level + 2
        unless @timeformat
          out << i("timeformat \"#{@timeformawpt}\"") end
        unless @currency
          out << i("currency \"#{@currency}\"") end
        unless @timingresolution
          out << i("timingresolution \"#{@timingresolution}\"") end
        unless @dailyworkinghours
          out << i("dailyworkinghours \"#{@dailyworkinghours}\"") end

        out << i("extend task {")
        out << i("  number Redmine 'Redmine'")
        out << i("}")
        if @now and not @now.empty?
          out << i("now #{@now}")
        end

        @level = level - 2
        out += "}"

        return out
      end
    end
  end
end
