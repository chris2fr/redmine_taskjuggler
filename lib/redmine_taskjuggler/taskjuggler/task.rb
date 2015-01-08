#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction module for TaskJuggler data model
  #
  module Taskjuggler
    module Task
      @flags = []
      class Task
        attr_accessor :id,
          :localId,
          :parent,
          :children,
          :name,
          # :complete,
          :flags,
          :note,
          :timeEffort, # Where does it start and how long does it take
          :issueEtc
          :sourceObj

        def id
          if parent == nil
            return @localId
          else
            return @parent.id + '.' + @localId
          end
        end

        def to_tjp(level=0)
          @level = level
          def i(s)
            s.gsub(/^/, ' '*@level) << "\n"
          end
          out = i("task #{@localId} \"#{@name}\" {")
          @level = @level+2
          if @timeEffort
            out << "#{@timeEffort.to_tjp(@level)}"
          end
          if not @flags.empty?
            out << i("flags #{@flags.join(", ")}")
          end
          if @issueEtc and not @issueEtc.empty?
            out << i("#{@issueEtc}")
          end
          if @note and not @note.empty?
            out << i("note -8<-")
            out << i(@note)
            out << i("->8-")
          end
          @children.each do |child|
            out << child.to_tjp(@level)
          end
          @level = @level-2
          out << i("}")
          return out
        end
      end
      class FromProject < Task
        def initialize(project, parent=nil)
          @localId = project.identifier.gsub(/-/,'_')
          @name = project.name
          @parent = parent
          @children = []
          @flags = ['Redmine', 'RedmineProject']
          @note = project.description
          @issueEtc = nil
        end
      end
      class FromIssue < Task
        def initialize(issue, parent=nil)
          @localId = 'T' + issue.id.to_s
          @name = issue.subject
          @parent = parent
          @children = []
          @flags = ['Redmine', 'RedmineIssue']
          @note = issue.description
          @issueEtc = issue.tj_issue_etc
          @sourceObj = 'issue'

          # TODO improve allocation/depends/etc… stuff
          if issue.tj_scheduled
            @timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
              RedmineTaskjuggler::Taskjuggler::TimePointStart.new(child.start_date),
              RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(child.due_date)
            )

          elsif issue.tj_allocates.empty?

            # resolve depends
            depends = IssueRelation.find(
              :all,
              :conditions => {:issue_to_id => 2,
                              :relation_type => [IssueRelation::TYPE_PRECEDES,
                                                 IssueRelation::TYPE_BLOCKS]}
            ).each do |issue_from|
              @visited_issues[issue_from]
            end

            if depends.empty?
              start_point = RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
            else
              start_point = RedmineTaskjuggler::Taskjuggler::TimePointDepends.new(depends)
            end

            if start_point.empty?
              if issue.children.empty?
                @timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
                  RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                  RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                  RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
                  RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
                  RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                )
              else
                @timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
                  RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
                  RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                  [],
                  RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
                  RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
                )
              end
            else
              @timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
                # TODO: Better determine start
                start_point,
                RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
                RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h'),
                RedmineTaskjuggler::Taskjuggler::Priority.new([issue.tj_priority]),   # add Priority for Issue
                RedmineTaskjuggler::Taskjuggler::TaskLimits.new([issue.tj_limits])    # add Limits for Issue
              )
            end

          elsif issue.start_date? and issue.due_date?
            @timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
              # TODO: Revisit TimePoint Null and TimePoint
              RedmineTaskjuggler::Taskjuggler::TimePointStart.new(issue.start_date),
              RedmineTaskjuggler::Taskjuggler::TimePointEnd.new(issue.due_date)
            )
          end

        end
      end
    end
  end
end
