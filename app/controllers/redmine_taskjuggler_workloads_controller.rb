require_dependency 'redmine_workload'

#
# Redmine Taskjuggler Projects controller
#
class RedmineTaskjugglerWorkloadController < ApplicationController
  unloadable
  
  # :params['user_id'] - the current user
  # :params['current_date'] - the date around which we will work
  # :params['interval'] - the days before and after the current date
  def index # From timetable
    #@current_date = get_current_date(params)
    #@current_user_id = get_current_user_id(params)
    #@current_user = User.find(@current_user_id)

    rtjwl = new RedmineTaskjugglerWorkload(params)

    @users = User.find(:all,:order => ['firstname'])
    projects = Project.find(:all, :conditions => {:status => 1}, :order => ['parent_id,name'])
    @project_list = {}
    @category_list = {}
    @status_list = {}
    @tracker_list = {}
    trackers = Tracker.find(:all)
    trackers.each do |tracker|
      @tracker_list[tracker.id] = tracker
    end
    statuses = IssueStatus.find(:all)
    statuses.each do |status|
      @status_list[status.id] = status
    end
    projects.each do |project|
      @project_list[project.id] = project
      cats = IssueCategory.find(:all,:conditions => {:project_id => project.id},:order => ['name'])
      cats.each do |cat|
	      @category_list[cat.id] = cat
      end
    end
    #projet
    @hours_total = 0
    @time_entries_hours = {}
    @time_entries_comments = {}
    # Time-logged issues
    @logged_issues = {}
    time_entries = TimeEntry.find(:all,:conditions => {:user_id => rtjwl.current_user_id, :spent_on => rtjwl.current_date})
    if time_entries
      seen_te = {}
      time_entries.each do |time_entry|
	if time_entry.hours > 8
	  time_entry.hours = 8
	  time_entry.save()
	end
	# Fuse all multiple te for a same date
	if seen_te.has_key?(time_entry.issue_id)
	  seen_te[time_entry.issue_id].hours += time_entry.hours
	  if time_entry.comments
		  seen_te[time_entry.issue_id].comments += " + " + time_entry.comments
	  end
	  @hours_total += time_entry.hours
	  seen_te[time_entry.issue_id].save()
	  TimeEntry.delete(time_entry.id)
	  @logged_issues[time_entry.issue_id] = get_spent_hours(time_entry.issue_id, rtjwl.current_user_id,rtjwl.current_date)
	else
	  seen_te[time_entry.issue_id] = time_entry
	  @logged_issues[time_entry.issue_id] = Issue.find(:first,:conditions => {:id => time_entry.issue_id})
	  @time_entries_hours[time_entry.issue_id] = get_spent_hours(time_entry.issue_id, rtjwl.current_user_id,rtjwl.current_date)
	  @hours_total += time_entry.hours
	  if @time_entries_hours[time_entry.issue_id] > 0
	    @time_entries_comments[time_entry.issue_id] = time_entry.comments
	  end
	end
      end
    end
    # Assigned issues
    @assigned_issues = {}
    issues = Issue.find(:all, :conditions => ["assigned_to_id = " + rtjwl.current_user_id.to_s()], :order => ["project_id, category_id, id"] )
    issues.each do |issue|
      unless (@logged_issues and @logged_issues[issue.id]) or (issue.start_date and issue.start_date > rtjwl.current_date) or (issue.due_date and issue.due_date < @current_date) or
      (issue.status.is_closed and (not issue.start_date or not issue.due_date))
	#@time_entries_hours[issue.id] = get_spent_hours(issue.id, params[:user_id],params[:date])
	@assigned_issues[issue.id] = issue
      end
    end
    # Watched issues
    watched = Watcher.find(:all, :conditions => {:user_id => rtjwl.current_user_id, :watchable_type => "issue"})
    @watched_issues = {}
    watched.each do |watched_issue|
      issue = watched_issue.watchable
      unless (@logged_issues and @logged_issues[watched_issue.watchable_id]) or (@assigned_issues and @assigned_issues[watched_issue.watchable_id]) or
      (issue.start_date and issue.start_date > rtjwl.current_date) or (issue.due_date and issue.due_date < rtjwl.current_date) or
      (issue.status.is_closed and (not issue.start_date or not issue.due_date))
	      @watched_issues[watched_issue.watchable_id] = Issue.find(:first, :conditions => {:id => watched_issue.watchable_id})
      end
    end
    @user = User.find(:first, :conditions => ["id = " + rtjwl.current_user_id.to_s()])
  end
  
  def new
  end
  
  def create
  end
  
  def show # From timetable_summary
    rtjwl = new RedmineTaskjugglerWorkload(params)
    rtjwl.get_timetable_info()
  end
  
  def edit # From summary
    # config.logger = Logger.new(STDOUT)
    # logger = Logger.new(STDOUT)
    # logger.log_level = Logger::DEBUG
    rtjwl = new RedmineTaskjugglerWorkload(params)

    #@current_date = RedmineTaskjugglerWorkload::get_current_date(params)
    
    @start_date = params[:start_date] ? Date::parse(params[:start_date]) : @current_date - rtjwl.interval # was 10
    @end_date = params[:end_date] ? Date::parse(params[:end_date]) : @current_date + rtjwl.interval # was 30
    
    # @current_user_id = get_current_user_id(params)
    # interval = params.has_key?("interval") ? params[:interval] : 15
    conditions = ' spent_on > "' + (rtjwl.current_date - rtjwl.interval).to_s() + '" AND spent_on < "' + (rtjwl.current_date - rtjwl.interval).to_s() + '"'
    @logged_te = TimeEntry.find(:all,:conditions => [conditions], :order => ['issue_id,spent_on'] )
    @logged_days = {}
    @total_days = {}
    @projcat = {}
    @projects = Project.find(:all, :conditions => {:status => 1}, :order => ['parent_id,name'])
    @projects.each do |projet|
      @projcat[projet.id] = {}
      @projcat[projet.id]["total"] = 0.0
      @projcat[projet.id]["other"] = {}
      @projcat[projet.id]["other"]["total"] = 0.0
      # issue_categories = projet.issue_categories
      projet.issue_categories.each do |cat|
        @projcat[projet.id][cat.id] = {}
        @projcat[projet.id][cat.id]["total"] = 0.0
      end
    end
    @logged_te.each do |te|
      if te.spent_on and te.issue.project
        cat_id = te.issue.category ? te.issue.category.id : "other"
        logger.debug ("cat_id")
        logger.debug (cat_id)
        unless @projcat[te.issue.project.id][cat_id].has_key?(te.spent_on.to_s())
                @projcat[te.issue.project.id][cat_id][te.spent_on.to_s()] = 0.0
        end
        @projcat[te.issue.project.id][cat_id][te.spent_on.to_s()] += te.hours.to_f() / 8
        @projcat[te.issue.project.id][cat_id]["total"] += te.hours.to_f() / 8
        unless @total_days.has_key?(te.spent_on.to_s())
                @total_days[te.spent_on.to_s()] = {}
                @total_days[te.spent_on.to_s()]["total"] = 0.0
        end
        unless @total_days[te.spent_on.to_s()].has_key?(te.project.id)
                @total_days[te.spent_on.to_s()][te.project.id] = 0.0
        end
        @total_days[te.spent_on.to_s()]["total"] += te.hours.to_f() / 8
        @projcat[te.issue.project.id]["total"] += te.hours.to_f() / 8
        ####@projcat[te.issue.project.id][cat_id]["total"] += te.hours.to_f() / 8
        @total_days[te.spent_on.to_s()][te.project.id] += te.hours.to_f() / 8
      end
    end
  end
  
  def update # From timetable_update
    rtjwl = new RedmineTaskjugglerWorkload(params)
    @current_user = User.find(rtjwl.current_user_id)
    #
    # UPDATE PART
    #
    ## See if the project has activities or not
    act_id = TimeEntryActivity.find(:first ).id
    ## Update each time entry for the user, the day, the issue
    params[:time_entry].each do |issue_id, hours|
      @spent_hours = rtjwl.get_spent_hours(issue_id,params[:date])
      # Non-zero time entry to add
      if (@spent_hours == 0.0 and hours != "0")  # Ajouter TimeEntry
	te = TimeEntry.create()
	te.hours = hours.to_i()
	te.activity_id = act_id
	issue = Issue.find(issue_id)
	te.project_id = issue.project_id
	te.issue_id = issue_id.to_i()
	te.user_id = params[:user_id]
	te.spent_on = params[:date]
	te.comments = params[:time_entires_comments][issue_id.to_s()]
	issue = Issue.find(issue_id)
	issue.estimated_hours = (params[:issues_estimates][issue_id.to_s()].to_f() * 8.0).to_i()
	issue.save()
	te.save()
      # Non-zero time-entry to delete
      elsif @spent_hours != 0 and hours == "0"#  and hours == "0" # Supprimer
	TimeEntry.delete(TimeEntry.find(:first, :conditions => {:user_id => params[:user_id].to_i(),:issue_id => issue_id, :spent_on => params[:date]}).id)
      # Non-zero time-entry to update
      elsif @spent_hours != 0 #hours.to_f()
	te = TimeEntry.find(:first, :conditions => {:user_id => params[:user_id].to_i(),:issue_id => issue_id.to_i(), :spent_on => params[:date]})
	if te
	  te.hours = hours
	  te.comments = params[:time_entires_comments][issue_id.to_s()].to_s()
	  issue = Issue.find(issue_id)
	  issue.estimated_hours = (params[:issues_estimates][issue_id.to_s()].to_f() * 8.0).to_i()
	  issue.save()
	  te.save()
	end
      end
    end
    #
    # TIMESHEET PRODUCTION PART
    #
    rtjwl.get_timetable_info()
  end
  
  def destroy
  end
  
end