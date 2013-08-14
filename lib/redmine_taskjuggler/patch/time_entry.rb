require_dependency 'time_entry'

module RedmineTaskjuggler
  module Patch
    # Patches Redmine's Projects dynamically.
    module TimeEntry
      extend ActiveSupport::Concern
      included do
        extend ClassMethods
        attr_accessible :tj_starttime
      end
      
      module ClassMethods
         
      end
      
      module InstanceMethods
         
      end
    end
  end
end

TimeEntry.send(:includes,RedmineTaskjuggler::Patch::TimeEntry)
TimeEntry.send(:includes,RedmineTaskjuggler::Patch::TimeEntry::InstanceMethods)
TimeEntry.safe_attributes :tj_starttime