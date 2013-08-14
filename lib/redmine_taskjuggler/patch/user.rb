require_dependency 'user'

module RedmineTaskjuggler
  module Patch
    # Patches Redmine's Users dynamically.
    module User
      extend ActiveSupport::Concern
      included do
        extend ClassMethods
        attr_accessible :tj_activated,
          :tj_parent,
          :tj_rate,
          :tj_vacations,
          :tj_limits
      end
      
      module ClassMethods
         
      end
      
      module InstanceMethods
         
      end
    end
  end
end

User.send(:includes,RedmineTaskjuggler::Patch::User)
User.send(:includes,RedmineTaskjuggler::Patch::User::InstanceMethods)
User.safe_attributes :tj_activated,
          :tj_parent,
          :tj_rate,
          :tj_vacations,
          :tj_limits