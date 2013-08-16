module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
  module Redmine
    
    class Project
      
      attr_accessor :id,
        :identifier,
        :name,
        :parent,
        :children,
        :description
      
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