#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    ##
    # I think this class may be redoundant with the Settings in Redmine.
    # I don't know what this is nor if it is used. It looks like a hashtable.
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
