#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    class Issue
      attr_accessor :id,
        :identifier,
        :subject,
        :start_date,
        :due_date,
        :done_ratio,
        :parent,
        :children,
        :project,
        :description,
        :assigned_to, # User
        :estimated_hours,
        :priority,
	:category,
	:issue_etc
    end
    class IssuePriority
      
    end
  end
end
