require_dependency 'issue'
require_dependency 'user'

module RedmineTaskjuggler
  module Patch
    # Patches Redmine's Issues dynamically.
    module Issue
      extend ActiveSupport::Concern
      included do
        extend ClassMethods
        attr_accessible :tj_activated,
            :tj_depends,
            :tj_preceeds,
            :tj_parent,
            :tj_scheduled,
            :tj_allocates, # Users
            :tj_limits
      end
      
      module ClassMethods
         
      end
      
      module InstanceMethods
         
      end
      
    end
  end
end

Issue.send(:includes,RedmineTaskjuggler::Patch::Issue)
Issue.send(:includes,RedmineTaskjuggler::Patch::Issue::InstanceMethods)
Issue.safe_attributes :tj_activated,
            :tj_depends,
            :tj_preceeds,
            :tj_parent,
            :tj_scheduled,
            :tj_allocates, # Users
            :tj_limits