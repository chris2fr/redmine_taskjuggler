# encoding: utf-8
require_dependency 'redmine_taskjuggler'
##
# Redmine Taskjuggler Projects controller
#
class RedmineTaskjugglerWorkloadsController < ApplicationController
  unloadable
  
  ##
  # Previously known as #timetable should be show
  # :params['user_id'] - the current user
  # :params['current_date'] - the date around which we will work
  # :params['interval'] - the days before and after the current date
  def index # From timetable
    #@current_date = get_current_date(params)
    #@current_user_id = get_current_user_id(params)
    #@current_user = User.find(@current_user_id)

    @rtjwl = getRedmineTaskjugglerWorkload(params)

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
    time_entries = TimeEntry.find(:all,:conditions => {:user_id => @rtjwl.user_id, :spent_on => @rtjwl.current_date})
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
	  @logged_issues[time_entry.issue_id] = get_spent_hours(@rtjwl.user_id, time_entry.issue_id,@rtjwl.current_date)
	else
	  seen_te[time_entry.issue_id] = time_entry
	  @logged_issues[time_entry.issue_id] = Issue.find(:first,:conditions => {:id => time_entry.issue_id})
	  @time_entries_hours[time_entry.issue_id] = get_spent_hours(@rtjwl.user_id, time_entry.issue_id, @rtjwl.current_date)
	  @hours_total += time_entry.hours
	  if @time_entries_hours[time_entry.issue_id] > 0
	    @time_entries_comments[time_entry.issue_id] = time_entry.comments
	  end
	end
      end
    end
    # Assigned issues
    @assigned_issues = {}
    issues = Issue.find(:all, :conditions => ["assigned_to_id = " + @rtjwl.user_id.to_s()], :order => ["project_id, category_id, id"] )
    #puts issues
    issues.each do |issue|
      #puts "\n\n=======================================\n\n Issue Start Date"
      #puts issue.start_date + " ISSUE DUE DATE : " + issue.due_date + " : Current Date : " + rtjwl.current_date
      #puts "\n\n=======================================\n\n"
      unless (@logged_issues and @logged_issues[issue.id])
	unless (issue.start_date and (issue.start_date > @rtjwl.current_date))
	  unless (issue.status.is_closed and (not issue.start_date or not issue.due_date))
	    @assigned_issues[issue.id] = issue
	  end
	end
      end
    end
    # Watched issues
    watched = Watcher.find(:all, :conditions => {:user_id => @rtjwl.user_id, :watchable_type => "issue"})
    @watched_issues = {}
    watched.each do |watched_issue|
      issue = watched_issue.watchable
      unless (@logged_issues and @logged_issues[watched_issue.watchable_id]) 
      	unless (@assigned_issues and @assigned_issues[watched_issue.watchable_id]) 
      	  unless (issue.start_date and issue.start_date > @rtjwl.current_date) 
      	    unless (issue.due_date and issue.due_date < @rtjwl.current_date) 
      	      unless (issue.status.is_closed and (not issue.start_date or not issue.due_date))
      	        @watched_issues[watched_issue.watchable_id] = Issue.find(:first, :conditions => {:id => watched_issue.watchable_id})
      	      end
      	    end
      	  end
      	end
      end
    end
    @user = User.find(:first, :conditions => ["id = " + @rtjwl.user_id.to_s()])
  end
  
  def new
  end
  
  def create
  end
  
  def show # From timetable_summary
    @rtjwl = getRedmineTaskjugglerWorkload(params)
    get_timetable_info @rtjwl.user_id, @rtjwl.current_date, @rtjwl.interval
  end
  
  
  def edit # From summary
    # config.logger = Logger.new(STDOUT)
    # logger = Logger.new(STDOUT)
    # logger.log_level = Logger::DEBUG
    @rtjwl = getRedmineTaskjugglerWorkload(params)

    #@rtjwl.current_date = RedmineTaskjugglerWorkload::get_current_date(params)
    
  end
  
  def update # From timetable_update
    @rtjwl = getRedmineTaskjugglerWorkload(params)
    @current_user = User.find(@rtjwl.user_id)
    #
    # UPDATE PART
    #
    ## See if the project has activities or not
    act_id = TimeEntryActivity.find(:first ).id
    ## Update each time entry for the user, the day, the issue
    params[:time_entry].each do |issue_id, hours|
      @spent_hours = get_spent_hours(@rtjwl.user_id,issue_id,params[:date])
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
    #puts @rtjwl.current_date
    get_timetable_info @rtjwl.user_id, @rtjwl.current_date, @rtjwl.interval
  end
  
  def destroy
  end
  
  #
  # Utility functions
  #

  ##
  # Check to see if redoundant with get_timetable_info
  def getRedmineTaskjugglerWorkload(params)
    @rtjwl = RedmineTaskjugglerWorkload.new
    if params[:user_id]
      @rtjwl.user_id = params[:user_id].to_i()
    else
      @rtjwl.user_id = User.current.id.to_i()
    end
    if params[:date]
      @rtjwl.current_date = Date::parse(params[:date])
    end
    if not @rtjwl.current_date.is_a?(Date)
      now = DateTime::now()
      @rtjwl.current_date = Date::civil(now.year,now.month,now.mday)
    end
    if params[:interval]
      @rtjwl.interval = interval
    else
      @rtjwl.interval = 30
    end
    
    @start_date = params[:start_date] ? Date::parse(params[:start_date]) : @rtjwl.current_date - @rtjwl.interval # was 10
    @end_date = params[:end_date] ? Date::parse(params[:end_date]) : @rtjwl.current_date + @rtjwl.interval # was 30
    
    # @current_user_id = get_current_user_id(params)
    # interval = params.has_key?("interval") ? params[:interval] : 15
    conditions = ' spent_on > "' + (@rtjwl.current_date - @rtjwl.interval).to_s() + '" AND spent_on < "' + (@rtjwl.current_date - @rtjwl.interval).to_s() + '"'
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
    @rtjwl
  end

  ##
  # Returns the formatted timetable mainly for consulting
  # user_id integer
  # current_date String I guess
  # interval integer
  def get_timetable_info (user_id, current_date, interval)
    puts @rtjwl.current_date
    #@logged_te = @rtjwl.get_time_entries
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
      # issue_categories = projet.issue_categories
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
  
  ##
  # This my be redoundant. I think I do the same calculation differently, but not as artful.
  def get_spent_hours(user_id,issue_id,date)
    te = TimeEntry.find(:first,:conditions => {:user_id => user_id, :spent_on => date, :issue_id => issue_id})
    if te
            spent_hours = te.hours
    else
            spent_hours = 0.0
    end
    #puts issue_id + " Spent hours : " + spent_hours
    return spent_hours
  end
  
  ##
  # I am not sure I still use this. It seems that versions and categories
  # are no longer used.
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


end
