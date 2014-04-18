require_dependency 'redmine_workload'
require_dependency 'redmine_workload'

#
# Utility functions
#

    def get_current_user_id(params)
      if params[:user_id]
        current_user_id = params[:user_id].to_i()
      else
        current_user_id = User.current.id.to_i()
      end
      return current_user_id
    end
  
    def get_current_date(params)
      if params[:date]
        current_date = Date::parse(params[:date])
      else
        now = DateTime::now()
        current_date = Date::civil(now.year,now.month,now.mday)
      end
      return current_date
    end
  
    def get_timetable_info(current_date, interval, user_id)
      conditions = 'user_id = '+ user_id.to_s() + ' AND spent_on > "' + (current_date - interval).to_s() + '" AND spent_on < "' + (current_date + interval).to_s() + '"'
      @logged_te = TimeEntry.find(:all,:conditions => [conditions], :order => ['issue_id,spent_on'] )
      @logged_issues = {}
      @logged_days = {}
      @total_days = {}
      @projcat = {}
      @projects = Project.find(:all, :conditions => {:status => 1}, :order => ['parent_id,name'])
      @projects.each do |projet|
        @projcat[projet.id] = {}
        @projcat[projet.id]["total"] = 0.0
        issue_categories = projet.issue_categories
        projet.issue_categories.each do |cat|
                @projcat[projet.id][cat.id] = {}
        end
      end
      @logged_te.each do |te|
        unless @logged_issues.has_key?(te.issue_id)
          @logged_issues[te.issue_id] = Issue.find(:first, :conditions => {:id => te.issue_id})
          @logged_days[te.issue_id] = {}
          #(-29..29).each do |delta|
          #	@logged_days[te.issue_id][(@date + delta).to_s()] = 0
          #end
        end
        if te.spent_on
          @logged_days[te.issue_id][te.spent_on.to_s()] = te.hours.to_f() / 8
          @projcat = add_to_projcat(@projcat, te.issue.project, te.issue.category, te) 
          unless @total_days.has_key?(te.spent_on.to_s())
                  @total_days[te.spent_on.to_s()] = te.hours.to_f() / 8
          else
                  @total_days[te.spent_on.to_s()] += te.hours.to_f() / 8
          end
        end
      end
    end
  
    def get_spent_hours(issue_id,user_id,date)
      te = TimeEntry.find(:first,:conditions => {:user_id => user_id, :spent_on => date, :issue_id => issue_id})
      if te
              spent_hours = te.hours
      else
              spent_hours = 0.0
      end
      #puts issue_id + " Spent hours : " + spent_hours
      return spent_hours
    end
  
    def add_to_projcat(projcat, proj, cat, te)
      unless projcat.has_key?(proj.id)
        projcat[proj.id] = {}
        projcat[proj.id]["total"] = 0.0
      end
      #unless projcat[proj.id].has_key?("total")
      #	projcat[proj.id]["total"] = 0.0
      #end
      unless cat
        cat_id = "other"
      end
      unless projcat[proj.id].has_key?(cat_id)
        projcat[proj.id][cat_id] = {}
        projcat[proj.id][cat_id]["total"] = 0.0
      end
      projcat[proj.id][cat_id][te.spent_on.to_s()] = te.hours.to_f() / 8.0
      projcat[proj.id][cat_id]["total"] += te.hours.to_f() / 8.0
      #projcat[proj.id]["total"] += te.hours.to_f() / 8.0
      return projcat
    end

#
# Redmine Workload main controller
#
class RedmineWorkloadController < ApplicationController
  unloadable
  
  def timetable_summary
    @current_date = get_current_date(params)
    @current_user_id = get_current_user_id(params)
    @current_user = User.find(@current_user_id)
    @interval = 30
    #@return = get_timetable_info(@date, @interval, @current_user_id)
    get_timetable_info(@current_date, @interval, @current_user_id)
  end

  def timetable_update
    @current_date = get_current_date(params)
    @current_user_id = get_current_user_id(params)
    @current_user = User.find(@current_user_id)
    #
    # UPDATE PART
    #
    ## See if the project has activities or not
    act_id = TimeEntryActivity.find(:first ).id
    ## Update each time entry for the user, the day, the issue
    params[:time_entry].each do |issue_id, hours|
      @spent_hours = get_spent_hours(issue_id,params[:user_id].to_i(),params[:date])
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
    @current_date = Date::parse(params[:date])
    @interval = 30
    @current_user_id = params[:user_id]
    get_timetable_info(@current_date, @interval, @current_user_id)
  end

  def timetable
    @current_date = get_current_date(params)
    @current_user_id = get_current_user_id(params)
    @current_user = User.find(@current_user_id)

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
    time_entries = TimeEntry.find(:all,:conditions => {:user_id => @current_user_id, :spent_on => @current_date})
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
	  @logged_issues[time_entry.issue_id] = get_spent_hours(time_entry.issue_id, @current_user_id,@current_date)
	else
	  seen_te[time_entry.issue_id] = time_entry
	  @logged_issues[time_entry.issue_id] = Issue.find(:first,:conditions => {:id => time_entry.issue_id})
	  @time_entries_hours[time_entry.issue_id] = get_spent_hours(time_entry.issue_id, @current_user_id,@current_date)
	  @hours_total += time_entry.hours
	  if @time_entries_hours[time_entry.issue_id] > 0
	    @time_entries_comments[time_entry.issue_id] = time_entry.comments
	  end
	end
      end
    end
    # Assigned issues
    @assigned_issues = {}
    issues = Issue.find(:all, :conditions => ["assigned_to_id = " + @current_user_id.to_s()], :order => ["project_id, category_id, id"] )
    issues.each do |issue|
      unless (@logged_issues and @logged_issues[issue.id]) or (issue.start_date and issue.start_date > @current_date) or (issue.due_date and issue.due_date < @current_date) or
      (issue.status.is_closed and (not issue.start_date or not issue.due_date))
	#@time_entries_hours[issue.id] = get_spent_hours(issue.id, params[:user_id],params[:date])
	@assigned_issues[issue.id] = issue
      end
    end
    # Watched issues
    watched = Watcher.find(:all, :conditions => {:user_id => @current_user_id, :watchable_type => "issue"})
    @watched_issues = {}
    watched.each do |watched_issue|
      issue = watched_issue.watchable
      unless (@logged_issues and @logged_issues[watched_issue.watchable_id]) or (@assigned_issues and @assigned_issues[watched_issue.watchable_id]) or
      (issue.start_date and issue.start_date > @current_date) or (issue.due_date and issue.due_date < @current_date) or
      (issue.status.is_closed and (not issue.start_date or not issue.due_date))
	      @watched_issues[watched_issue.watchable_id] = Issue.find(:first, :conditions => {:id => watched_issue.watchable_id})
      end
    end
    @user = User.find(:first, :conditions => ["id = " + @current_user_id.to_s()])
  end

  def index
  end
  
  def summary
    #config.logger = Logger.new(STDOUT)
    logger = Logger.new(STDOUT)
    #logger.log_level = Logger::DEBUG

    @current_date = get_current_date(params)
    
    @start_date = params[:start_date] ? Date::parse(params[:start_date]) : @current_date - 10
    @end_date = params[:end_date] ? Date::parse(params[:end_date]) : @current_date + 30
    
    @current_user_id = get_current_user_id(params)
    interval = params.has_key?("interval") ? params[:interval] : 15
    conditions = ' spent_on > "' + (@current_date - interval).to_s() + '" AND spent_on < "' + (@current_date + interval).to_s() + '"'
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
      issue_categories = projet.issue_categories
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
end
