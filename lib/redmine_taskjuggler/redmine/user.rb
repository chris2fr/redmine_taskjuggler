#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    ##
    # Proxy class for a Redmine User
    class User
      ##
      # Will be used as identification
      attr_accessor :login
      ##
      # 
      attr_accessor :firstname
      ##
      # 
      attr_accessor :lastname
      ##
      # 
      attr_accessor :mail
      ##
      # 
      attr_accessor :team
    end
  end
end
