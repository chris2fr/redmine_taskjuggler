#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    ##
    # Proxy class representing a Redmine Issue with Redmine Issue attributes
    class Issue
      ##
      # Numeric ID of Redmine::Issue
      attr_accessor :id
      ##
      # 
      attr_accessor :identifier
      ##
      # 
      attr_accessor :subject
      ##
      # 
      attr_accessor :start_date
      ##
      # 
      attr_accessor :due_date
      ##
      # 
      attr_accessor :done_ratio
      ##
      # 
      attr_accessor :parent
      ##
      # 
      attr_accessor :children
      ##
      # 
      attr_accessor :project
      ##
      # 
      attr_accessor :description
      ##
      # User
      attr_accessor :assigned_to
      ##
      #
      attr_accessor :estimated_hours
      ##
      # 
      attr_accessor :priority
      ##
      #
      attr_accessor :category
      ##
      # I am not sure what this is for here. Perhaps a mistake.
      # It could be used for custom fields perhaps in a hash array.
      attr_accessor :issue_etc
    end
    ##
    # Prox class representing issue priority
    class IssuePriority
      
    end
  end
end
