class TaskjugglerController < ApplicationController
unloadable

  def export
  end

  def import
	@aFile = File.new(params[:filepath], "r")
	@fields = []
	@aFile.readline.chomp.each(";") do |field|
		@fields.push(field.gsub("\"","").chomp(";"))
	end
	if @fields == ["Id","Start","End","Priority","Effort","Duration","Dependencies"] then @all = "is dandy" end
	@lines = []
	@aFile.each do |dataline|
		line = dataline.chomp.split(";")
		(0..4).each do |i|
			line[i] = line[i].gsub("\"","")
		end
		line[0] = line[0].sub(/^.*\.t([0-9]+)$/,'\1').to_i
		line[1] = line[1].to_date
		line[2] = line[2].to_date
		line[3] = line[3].to_i
		line[4] = line[4].to_f
		#line[5] = line[5].to_f
		#temp = line[6].split(", ")
		#line[6] = []
		#temp.each do |item|
		#	line[6].push(item.sub(/^.*\.t([0-9]+)$/,'\1').to_i)
		#end
		#.each .gsub("\"","").chomp(";")
		issue = Issue.find(:first, :conditions => {:id => line[0] })
		issue.start_date = line[1].to_s
		issue.due_date = line[2].to_s
		#@lines.push(issue)
		#issue.priority_id = (line[3] / 100) -1
		issue.estimated_hours = line[4] * 8
		#if line[4] == 0 
			#duration to place here
		#end
# ignore line 6 for the time being, but this may lead to errors when saving
		#issue.save
		#sd = issue.start_date.to_s
		if issue.save
			@lines.push(line)
		else
			@lines.push(["Task #" + line[0].to_s + " not imported due to errors"])
		end
	end
  end

  def index
	@projects = Project.find(:all, :conditions => ["status = 1 AND parent_id IS NOT NULL"], :order => ["parent_id, name"] )
	@users = User.find(:all)
  end

  def timetable_update
	@flag = "non"
	act_id = Enumeration.find(:first,:conditions => {:opt => "ACTI"} ).id
	params[:time_entry].each do |issue_id, hours|
		@spent_hours = get_spent_hours(issue_id,params[:user_id].to_i(),params[:date])
		#unless @spent_hours == hours.to_f()
			if (@spent_hours == 0.0 and hours != "0")  # Ajouter TimeEntry
				@te = TimeEntry.create()
				@te.hours = hours.to_i()
				@te.activity_id = act_id
				issue = Issue.find(:first,:conditions => {:id => issue_id})
				@te.project_id = issue.project_id
				@te.issue_id = issue_id.to_i()
				@te.user_id = params[:user_id]
				@te.spent_on = params[:date]
				@te.save()
			elsif @spent_hours != 0 and hours == "0"#  and hours == "0" # Supprimer
				TimeEntry.delete(TimeEntry.find(:first, :conditions => {:user_id => params[:user_id].to_i(),:issue_id => issue_id, :spent_on => params[:date]}).id)
				@flag = "oui"
			elsif @spent_hours != hours.to_f()
				@te = TimeEntry.find(:first, :conditions => {:user_id => params[:user_id].to_i(),:issue_id => issue_id, :spent_on => params[:date]})

				@te.hours = hours
				@te.save()
			end
		#end
	end
	@date = Date::parse(params[:date])
	@logged_te = TimeEntry.find(:all,:conditions => ['user_id = '+params[:user_id] + ' AND spent_on > "' + (@date - 30).to_s() + '" AND spent_on < "' + (@date + 30).to_s() + '"'], :order => ['issue_id,spent_on'] )
	@logged_issues = {}
	@logged_days = {}
	@logged_te.each do |te|
		unless @logged_issues.has_key?(te.issue_id)
			@logged_issues[te.issue_id] = Issue.find(:first, :conditions => {:id => te.issue_id})
			@logged_days[te.issue_id] = {}
			(-30..30).each do |delta|
				@logged_days[te.issue_id][(@date + delta).to_s()] = 0
			end
		end
		@logged_days[te.issue_id][te.spent_on] = te.hours.to_f() / 8
	end

  end

  def timetable
	if params[:user_id]
		@current_user_id = params[:user_id].to_i()
	else
		@current_user_id = User.current.id.to_i()
	end
	if params[:date]
		@current_date = params[:date]
	else
		now = DateTime::now()
		date = Date::civil(now.year,now.month,now.mday)
		@current_date = date.to_s()
		
	end
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
				if seen_te[time_entry.issue_id]
					
					seen_te[time_entry.issue_id].hours += time_entry.hours
					if time_entry.comments
						seen_te[time_entry.issue_id].comments += " " + time_entry.comments
					end
					
					@hours_total += time_entry.hours
					seen_te[time_entry.issue_id].save()
					TimeEntry.delete(time_entry.id)
				else
					seen_te[time_entry.issue_id] = time_entry
					@logged_issues[time_entry.issue_id] = Issue.find(:first,:conditions => {:id => time_entry.issue_id})
					@time_entries_hours[time_entry.issue_id] = get_spent_hours(time_entry.issue_id, @current_user_id,@current_date)
					@hours_total += time_entry.hours
				end
		end
	end
	# Assigned issues
	@assigned_issues = {}
	issues = Issue.find(:all, :conditions => ["assigned_to_id = " + @current_user_id.to_s()], :order => ["project_id, category_id, id"] )
	issues.each do |issue|
		unless (@logged_issues and @logged_issues[issue.id])
			#@time_entries_hours[issue.id] = get_spent_hours(issue.id, params[:user_id],params[:date])
			@assigned_issues[issue.id] = issue
		end
	end
	# Watched issues
	watched = Watcher.find(:all, :conditions => {:user_id => @current_user_id, :watchable_type => "issue"})
	@watched_issues = {}
	watched.each do |watched_issue|
		unless (@logged_issues and @logged_issues[watched_issue.watchable_id]) or (@assigned_issues and @assigned_issues[watched_issue.watchable_id])
			@watched_issues[watched_issue.watchable_id] = Issue.find(:first, :conditions => {:id => watched_issue.watchable_id})
		end
	end
	@user = User.find(:first, :conditions => ["id = " + @current_user_id.to_s()])


	#@time_entries = TimeEntry
  end

  def initial_export
	### Initialize necessary variables
	if params[:project_identifier] 
		@Project = Project.find(:first, :conditions => {:identifier => params[:project_identifier]})
		@project_id = @Project.id.to_s
	else
		@Project = Project.find(:first, :conditions => {:id => params[:project_id]})
		@project_id = params[:project_id]
	end
	@FirstIssue = Issue.find(:first, :order => ["start_date"], :conditions => ["start_date IS NOT NULL AND project_id = " + @project_id])
	@LastIssue = Issue.find(:first, :order => ["due_date DESC"],:conditions => {:project_id => @project_id})
	@IssueFullName = {}
	@Issues = Issue.find(:all, :conditions => {:project_id => @project_id})
	@Versions = Version.find(:all,:conditions => {:project_id => @project_id})
	@Cats = IssueCategory.find(:all, :conditions => {:project_id => @project_id} );
	@start_status_id = IssueStatus.find(:first, :conditions => ["is_default=?", true]).id
	@TimeEntries = TimeEntry.find(:all, :conditions => ["spent_on >= '" + @FirstIssue.start_date.to_s + "'"], :order => ['user_id, issue_id'])
	@IssuesSansVersion = Issue.find(:all, :conditions => ["project_id = " + @project_id + " AND fixed_version_id IS NULL"])
	@CustFieldId = {}
	### Update task juggler
	@TimeEntries.each do |te|
		if not te.issue.start_date
			te.issue.start_date = te.spent_on
		end
		if te.spent_on < te.issue.start_date
			te.issue.start_date = te.spent_on
		end
		if te.issue.due_date and te.spent_on > te.issue.due_date
			te.issue.due_date = te.spent_on
		end
		if te.issue.done_ratio == 0
			te.issue.done_ratio = 10
		end
		if te.issue.status and te.issue.status.is_closed and not te.issue.done_ratio == 100
			te.issue.done_ratio = 100
		end
		te.issue.save
	end
	
	### Handle init des custom fields
	@CustFieldId['issue'] = {}
	@CustFieldId['issue']['milestone'] = IssueCustomField.find(:first, :conditions => {:name => "milestone"}).id
	@CustFieldId['issue']['allocate_alternative'] = IssueCustomField.find(:first, :conditions => {:name => "allocate_alternative"}).id
	@CustFieldId['issue']['allocate_additional'] = IssueCustomField.find(:first, :conditions => {:name => "allocate_additional"}).id
	@CustFieldId['issue']['allocate_squad'] = IssueCustomField.find(:first, :conditions => {:name => "allocate_squad"}).id
	@CustFieldId['issue']['duration'] = IssueCustomField.find(:first, :conditions => {:name => "duration"}).id
	@CustFieldId['issue']['scheduled']= IssueCustomField.find(:first, :conditions => {:name => "scheduled"}).id
	@CustFieldId['project'] = {}
	@CustFieldId['project']['start_date'] = ProjectCustomField.find(:first, :conditions => {:name => "start_date"}).id
	@CustFieldId['project']['stop_date'] = ProjectCustomField.find(:first, :conditions => {:name => "stop_date"}).id
	@CustFieldId['user'] = {}
	@CustFieldId['user']['squad'] = UserCustomField.find(:first, :conditions => {:name => "squad"}).id
	@CustFieldId['user']['limits'] = UserCustomField.find(:first, :conditions => {:name => "limits"}).id
	### Resources


	@Resources = @Project.assignable_users
	@ResourceSquadNames = UserCustomField.find(:first, :conditions => {:name => "squad"}).possible_values
	@ResourceSquadNames.push("others")
	@ResourceBySquad = {}
	@ResourceLimits = {} # Hash user_login => custom field "limits"
	if @ResourceSquadNames[0] 
		@ResourceSquadNames.each do |squad_name|
			if squad_name == "" then squad_name = "others" end
			@ResourceBySquad[squad_name] = {}
		end
	end
	@Resources.each do |res|
		squad_custom_value = res.custom_values.find(:first, :conditions => {:custom_field_id => @CustFieldId['user']['squad']})
		if squad_custom_value
			squad_name = squad_custom_value.value
		else
			squad_name = "others"
		end
		if squad_name == "" then squad_name = "others" end
		limits_custom_value = res.custom_values.find(:first, :conditions => {:custom_field_id => @CustFieldId['user']['limits']})
		if limits_custom_value and not limits_custom_value.value == ""
			@ResourceLimits[res.login.sub(".","_").sub("-","_")] = limits_custom_value.value
		end
		if @ResourceBySquad[squad_name]
			@ResourceBySquad[squad_name][res.login.sub(".","_").sub("-","_")] = res.firstname + " " + res.lastname + " <" + res.mail + ">"
		end
	end

	### Construct index of keys between issues and tasks
	@Issues.each do |issue|
		if issue.fixed_version
			@IssueFullName["t" + issue.id.to_s] = @Project.identifier.sub("-","_")
			@IssueFullName["t" + issue.id.to_s] = @IssueFullName["t" + issue.id.to_s] + ".v" + issue.fixed_version.name.sub(".","_").sub(" ","_").sub("-","_")

			if issue.category
				@IssueFullName["t" + issue.id.to_s] += "." + issue.category.name
			end
			@IssueFullName["t" + issue.id.to_s] = @IssueFullName["t" + issue.id.to_s] + ".t" + issue.id.to_s
		end		
	end
	### Construct a two-dimensional table of issues in categories in versions
	@IssuesByVersionByCat = {}
	@Versions.each do |version|
		version_name = "v" + version.name.sub(".","_").sub(" ","_").sub("-","_")
		if not @IssuesByVersionByCat[version_name]
			@IssuesByVersionByCat[version_name] = {}
		end
		issues = version.fixed_issues
		ret = self.PutIssuesByCat(issues)
		ret.each_pair do |cat_name, issues|
			@IssuesByVersionByCat[version_name][cat_name] = issues
		end
	end
  end

	def get_spent_hours (issue_id,user_id,date)
		te = TimeEntry.find(:first,:conditions => {:user_id => user_id, :spent_on => date, :issue_id => issue_id})
		if te
			spent_hours = te.hours
		else
			spent_hours = 0.0
		end
		#puts issue_id + " Spent hours : " + spent_hours
		return spent_hours
	end

	def PutIssuesByCat (issues)
		retvar = {}
		issues.each do |issue|
			if issue.category and issue.category.name
				cat_name = issue.category.name
			else
				cat_name = "no_category"
			end
			if not retvar[cat_name]
				retvar[cat_name] = []
			end
			retvar[cat_name].push(issue)
		end
		return retvar
	end
  def test
	
  end

end
