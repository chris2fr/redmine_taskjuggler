require_dependency 'user'
 
# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +has_many_and_belongs_to_many+ to User
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_and_belongs_to_many :users # forgot the "s"
    end
 
  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    # Wraps the association to get the Deliverable subject. Needed for the
    # Query and filtering
    def listusers
        return self.users
    end
  end
end
 
# Add module to Issue
Issue.send(:include, UserPatch)
 