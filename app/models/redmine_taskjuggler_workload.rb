class RedmineTaskjugglerWorkload < ActiveRecord::Base
  unloadable
  has_one :users
  attr_accessible :current_user_id, :current_date
  
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
  
  def initialize (params, interval = 30)
    @current_user_id = get_current_user_id(params)
    @current_date = get_current_date(params)
    @interval = interval
  end
  
  
  #
  # Utility functions
  #
  
  def get_timetable_info(interval = nil)
    if interval == nil
      interval = @interval
    end
    conditions = 'user_id = '+ @user_id.to_s() + ' AND spent_on > "' + (@current_date - interval).to_s() + '" AND spent_on < "' + (@current_date + interval).to_s() + '"'
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
  
  def get_spent_hours(issue_id,date)
    te = TimeEntry.find(:first,:conditions => {:user_id => @user_id, :spent_on => date, :issue_id => issue_id})
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
  
end
