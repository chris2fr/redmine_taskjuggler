#encoding: utf-8

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
