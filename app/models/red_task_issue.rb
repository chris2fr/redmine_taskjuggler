require_dependency 'issue'
#
# Represents a Redmine Issue mapped to a Taskjuggler Task
#
class RedIssue < ActiveRecord::Base
  unloadable
  #code
end
