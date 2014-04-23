#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    ##
    # Proxy class for a Redmine TimeEntry
    class TimeEntry
      ##
      # Numeric id in Redmine Database
      attr_accessor :id
      ##
      # 
      attr_accessor :user
      ##
      # 
      attr_accessor :issue
      ##
      # 
      attr_accessor :hours
      ##
      # 
      attr_accessor :comments
      ##
      # 
      attr_accessor :activity
    end
  end
end
