require_dependency 'time_entry'

module RedmineTaskjuggler
  module Patch
    # Patches Redmine's Projects dynamically.
    module TimeEntry
      extend ActiveSupport::Concern
      included do
        extend ClassMethods
        base.class_eval do
          attr_accessible :tj_start
        end
        base.class_eval do
          safe_attributes :tj_start
        end
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
TimeEntry.safe_attributes :tj_start