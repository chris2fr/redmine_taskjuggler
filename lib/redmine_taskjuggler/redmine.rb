require 'redmine_taskjuggler/redmine/project'
require 'redmine_taskjuggler/redmine/issue'
require 'redmine_taskjuggler/redmine/user'
require 'redmine_taskjuggler/redmine/time_entry'

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    class Settings
      def initialize
        @@settings ||= []
      end
      def get (name)
        @@settings[name]
      end
      def set (name, value)
        @@settings[name] = value
      end
    end
  end
end