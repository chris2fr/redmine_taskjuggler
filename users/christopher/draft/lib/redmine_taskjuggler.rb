#
# Class for getting Taskjuggler tasks from Redmine items
# and for setting Redmine item dates from a spefic
# Taskjuggler CSV export
#
class RedmineTaskjuggler
  attr_accessor :hoursPerDay
  attr_accessor :useCategories
  attr_accessor :useVersions
  attr_accessor :rootTask
  
  def updateFromTaskjugglerCSV pathToTaskjugglerCSVFile
    csvFile = TaskjugglerCSVFile.new self
    csvFile.import pathToTaskjugglerCSVFile
  end
  
  # Renders a string with the contents of a TaskJuggler tasks.tji file
  def exportToTaskjugglerTasks redmineProject
    
  end
  
end


#
# File handling classes
#
class RedmineTaskjugglerFile
  attr_accessor :redmineTaskjuggler
  
  def initialize redmineTaskjuggler
    @redmineTaskjuggler = redmineTaskjuggler
  end
end

#
# Task for handling a specific CVS import into Redmine
# from a Taskjuggler taskreport "Id","Start","End","Priority","Effort","Duration","Dependencies"
#
class TaskjugglerCSVFile < RedmineTaskjugglerFile
  
  def import pathToTaskjugglerCSVFile
    aFile = File.new(params[pathToTaskjugglerCSVFile], "r")
    fields = []
    aFile.readline.chomp.each(";") do |field|
      fields.push(field.gsub("\"","").chomp(";"))
    end
    if fields ==["Id","Start","End","Priority","Effort","Duration","Dependencies"] then
      all = "is dandy"
    end
    lines = [] aFile.each do |dataline|
      importLine dataLine
    end
  end
  
  def importLine dataLine
    line = dataline.chomp.split(";") (0..4).each do |i|
      line[i] = line[i].gsub("\"","")
    end
    line[0] = line[0].sub(/^.*\.t([0-9]+)$/,'\1').to_i
    line[1] = line[1].to_date
    line[2] = line[2].to_date
    line[3] = line[3].to_i
    line[4] = line[4].to_f
    #line[5] = line[5].to_f temp = line[6].split(", ") line[6] = []
    #temp.each do |item|
    #       line[6].push(item.sub(/^.*\.t([0-9]+)$/,'\1').to_i)
    #end .each .gsub("\"","").chomp(";")
    issue = Issue.find(:first, :conditions => {:id => line[0] })
    issue.start_date = line[1].to_s
    issue.due_date = line[2].to_s
    #@lines.push(issue) issue.priority_id = (line[3] / 100) -1
    issue.estimated_hours = line[4] * @redmineTaskjuggler.hoursPerDay
    #if line[4] == 0
      #duration to place here
    #end
    # ignore line 6 for the time being, but this may lead to errors
    # when saving
    #issue.save sd = issue.start_date.to_s
    if issue.save
      lines.push(line)
    else
      lines.push(["Task #" + line[0].to_s + " not imported due
      to errors"])
    end
  end
end

#
# Task for creating a string or file usable as a
# Taskjuggler include.
#
class TaskJugglerIncludeFile < RedmineTaskjugglerFile
  
  def export project
    projectId = project.id.to_s
    firstIssue = Issue.find(:first, :order => ["start_date"], :conditions => ["start_date IS NOT NULL AND project_id = " + projectId])
    lastIssue = Issue.find(:first, :order => ["due_date DESC"],:conditions => {:project_id => projectId})
    issueFullName = {}
    issues = project.issues
    versions = project.versions
    cats = project.issueCategories;
    startStatusId = IssueStatus.find(:first, :conditions => ["is_default=?", true]).id
    timeEntries = TimeEntry.find(:all, :conditions => ["spent_on >= '" + @FirstIssue.start_date.to_s + "'"], :order => ['user_id, issue_id'])
    issuesSansVersion = project.issues.find_by :fixed_version nil
    #     Issue.find(:all, :conditions => ["project_id = " + projectId + " AND fixed_version_id IS NULL"])
    # custFieldId = {}
    
    ### Update task juggler
    timeEntries.each do |te|
      cleanUpTimeEntries te
    end
      
    ### Handle init des custom fields
    #custFieldId['issue'] = {}
    #  @CustFieldId['issue']['milestone'] = IssueCustomField.find(:first, :conditions => {:name => "milestone"}).id
    #  @CustFieldId['issue']['allocate_alternative'] = IssueCustomField.find(:first, :conditions => {:name => "allocate_alternative"}).id
    #  @CustFieldId['issue']['allocate_additional'] = IssueCustomField.find(:first, :conditions => {:name => "allocate_additional"}).id
    #  @CustFieldId['issue']['allocate_squad'] = IssueCustomField.find(:first, :conditions => {:name => "allocate_squad"}).id
    #  @CustFieldId['issue']['duration'] = IssueCustomField.find(:first, :conditions => {:name => "duration"}).id
    #  @CustFieldId['issue']['scheduled']= IssueCustomField.find(:first, :conditions => {:name => "scheduled"}).id
    #  @CustFieldId['project'] = {}
    #  @CustFieldId['project']['start_date'] = ProjectCustomField.find(:first, :conditions => {:name => "start_date"}).id
    #  @CustFieldId['project']['stop_date'] = ProjectCustomField.find(:first, :conditions => {:name => "stop_date"}).id
    #  @CustFieldId['user'] = {}
    #  @CustFieldId['user']['squad'] = UserCustomField.find(:first, :conditions => {:name => "squad"}).id
    #  @CustFieldId['user']['limits'] = UserCustomField.find(:first, :conditions => {:name => "limits"}).id
    #  ### Resources


    resources = project.assignable_users
    # resourcesquadNames = UserCustomField.find(:first, :conditions => {:name => "squad"}).possible_values
    # resourcesquadNames.push("others")
    # resourceBySquad = {}
    resourceLimits = {} # Hash user_login => custom field "limits"
    #if resourcesquadNames[0] 
    #      resourcesquadNames.each do |squad_name|
    #                if squad_name == "" then squad_name = "others" end
    #                resourceBySquad[squad_name] = {}
    #        end
    #end
    resources.each do |res|
      res.extend TJ3Resource
      #squad_custom_value = res.custom_values.find(:first, :conditions => {:custom_field_id => @CustFieldId['user']['squad']})
      if res.tj3Squad
              squad_name = squad_custom_value.value
      else
              squad_name = "others"
      end
      if squad_name == "" then squad_name = "others" end
      
      #limits_custom_value = res.custom_values.find(:first, :conditions => {:custom_field_id => @CustFieldId['user']['limits']})
      if res.tj3Limits and not res.tj3Limits == ""
              resourceLimits[res.login.sub(".","_").sub("-","_")] = res.tj3Limits
      end
      if resourceBySquad[squad_name]
              resourceBySquad[squad_name][res.login.sub(".","_").sub("-","_")] = res.firstname + " " + res.lastname + " <" + res.mail + ">"
      end
    end

    ### Construct index of keys between issues and tasks
    issues.each do |issue|
      if issue.fixed_version
        issueFullName["t" + issue.id.to_s] = project.identifier.sub("-","_")
        issueFullName["t" + issue.id.to_s] = issueFullName["t" + issue.id.to_s] + ".v" + issue.fixed_version.name.sub(".","_").sub(" ","_").sub("-","_")
  
        if issue.category
          issueFullName["t" + issue.id.to_s] += "." + issue.category.name
        end
        issueFullName["t" + issue.id.to_s] = issueFullName["t" + issue.id.to_s] + ".t" + issue.id.to_s
      end		
    end
    ### Construct a three-dimensional table of issues in categories in versions
    issuesByVersionByCat = {}
    versions.each do |version|
            version_name = "v" + version.name.sub(".","_").sub(" ","_").sub("-","_")
            if not issuesByVersionByCat[version_name]
                issuesByVersionByCat[version_name] = {}
            end
            issues = version.fixed_issues
            ret = self.PutIssuesByCat(issues)
            ret.each_pair do |cat_name, issues|
                    issuesByVersionByCat[version_name][cat_name] = issues
            end
      end
  end
  
  def cleanUpTimeEntry te
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
  
end
