#encoding: utf-8

module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    ##
    # Proxy class for Redmine Project
    class Project
      ##
      # Numeric id of the Project
      attr_accessor :id
      ##
      # 
      attr_accessor :identifier
      ##
      # 
      attr_accessor :name
      ##
      # 
      attr_accessor :parent
      ##
      # 
      attr_accessor :children
      ##
      # 
      attr_accessor :description
      ##
      # Constructor with information from Redmine
      def initialize (id, identifier, name, description = "", parent = nil, children = [])
        @id = id
        @identifier = identifier
        @name = name
        @parent = parent
        @children = children
        @description = description
      
      end
    end
  end
end
