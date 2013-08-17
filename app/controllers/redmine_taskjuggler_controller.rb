require_dependency 'redmine_taskjuggler' 
#
# Redmine Taskjuggler main controller
#
class RedmineTaskjugglerController < ApplicationController
  unloadable
  
  # This is the index and only visible specific view
  def tjindex
    @project = Project.find(params[:id])
  end
  
  # This is a TJP download
  def tjp
    #include RedmineTaskjuggler
    @project = Project.find(params[:id])
        tjProject = RedmineTaskjuggler::Taskjuggler::Project.new(@project.identifier.gsub("-","_"),
        @project.to_s,
        @project.tj_period.to_s,
        @project.tj_now.to_s,
        @project.tj_version.to_s,
        @project.tj_dailyworkinghours.to_s,
        @project.tj_timingresolution.to_s
        )
    tjResources = []
    User.where(tj_activated: true).find_each do |user|
        tjResources.push(RedmineTaskjuggler::Taskjuggler::Resource.new(user.login.gsub(/-/,'_'),
                  user.firstname + ' ' + user.lastname,
                  user.tj_parent))
    end
    tjTasks = {}
    @project.issues.where(tj_activated: true).find_each do |issue|
      tjTask = RedmineTaskjuggler::Taskjuggler::Task.new('red' + issue.id.to_s,
        "[red#{issue.id}] " + issue.subject,
        nil,
        nil,
        [], #issue.tj_flags,
        issue.description
      )
      tjTasks[issue.id] = tjTask
    end
    tjTasks.keys.each do |redID|
      irs = IssueRelation.find(:all,
                                    :conditions => {:issue_to_id => redID,
                                    :relation_type => [IssueRelation::TYPE_PRECEDES,
                                      IssueRelation::TYPE_BLOCKS
                                    ]})
      # message += " issue " + issue.id.to_s + " irs.size #{irs.size} \n"
      if irs.size > 0
        depends = []
        irs.each {
          |ir|
          depends.push(RedmineTaskjuggler::Taskjuggler::Depend.new(
              # TODO: Use the issue object to get the correct TaskJuggler ID
              tjTasks[ir.issue_from_id],
              RedmineTaskjuggler::Taskjuggler::Gap.new(
                # TODO: the +1 is actually inaccurate here and needs adjusting with overload of issue or non-use of internal follows
                RedmineTaskjuggler::Taskjuggler::TimeSpan.new(ir.delay + 1, 'd')
              )
            )
          )
        }
        start_point = RedmineTaskjuggler::Taskjuggler::TimePointDepends.new(depends)
      else
        start_point = RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
      end
      issue = Issue.find(redID)
      if issue.tj_allocates
        tjTasks[redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortEffort.new(
          # TODO: Better determine start
          start_point,
          RedmineTaskjuggler::Taskjuggler::Allocate.new([issue.tj_allocates]),
          RedmineTaskjuggler::Taskjuggler::TimeSpan.new(issue.estimated_hours,'h')
        )
      elsif issue.tj_milestone
        tjTasks[redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortMilestone.new(
          # TODO: Revisit TimePoint Null and TimePoint
          # TODO: The format of start might not suffice as such
          issue.start || RedmineTaskjuggler::Taskjuggler::TimePointNil.new()
        )
      elsif issue.start? and issue.end?
        tjTasks[redID].timeEffort = RedmineTaskjuggler::Taskjuggler::TimeEffortStartStop.new(
          # TODO: Revisit TimePoint Null and TimePoint
          issue.start,
          issue.due_date
        )
      end
    end
    tjp = RedmineTaskjuggler::TJP.new(tjProject,tjResources,tjTasks.values)
    #tjp = RedmineTaskjuggler::TJP.new()
    send_data tjp.to_s, :filename => @project.identifier + "-" + @project.tj_version.to_s.gsub(/\./,"_") + ".tjp", :type => 'text/plain'
  end
  
  # This is a CSV upload
  def csv
    # Get the CSV File
    uploaded_io = params[:csvfile]
    #if uploaded_io[0,19] != '"Id";"Start";"End"'
    #  raise l(:exception_not_csv_issue_update)
    #end
    @lines = []
    CSV.foreach(uploaded_io.tempfile, :headers => true, :col_sep => ';') {|csvline|
      update_attributes = {'start_date' => csvline['Start'], 
        'due_date' => csvline['End']}
      issue = Issue.find(csvline["Redmine"])
      update_attributes.each { |r, t|  
        test = issue.update_attributes({r => t})
        unless test
          @lines.push(issue.errors.messages.inspect.to_s)
        end
      }
      @lines.push("#" + csvline["Redmine"].to_s + ". #{issue.subject} : #{issue.start_date} - #{issue.due_date} ")
    }
    # Parse the CSV File line by line
    # Update Redmine with the dates and effort
  end
end