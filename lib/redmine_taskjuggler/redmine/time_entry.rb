#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    class TimeEntry
      attr_accessor :id,
        :user,
        :issue,
        :hours,
        :comments,
        :activity
    end
  end
end
