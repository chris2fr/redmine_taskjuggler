#
# Augmenting the project functionality
#
class tj3RedmineProject < Project
  alias_method 	:issues :superIssues
  # Returns aumented issues
  def issues
    i = 0
    superIssuesCache = @superIssues
    while i < superIssuesCache.length
      superIssuesCache[i].extend tj3Task
      i += 1
    end
    return superIssuesCache
  end
  
  def to_tj3
    
  end
end



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

class tj3Task

  def to_tj3
    
  end
  
  # Renders the supplement task part from Redmine journal entries
  def to_tj3_booking
    
  end

end
