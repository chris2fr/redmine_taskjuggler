module RedmineTaskjuggler
  #
  # Abstraction module for TaskJuggler data model
  #
  module Taskjuggler
    @flags = []
    class Task
      attr_accessor :id,
        :localId,
        :parent,
        :children,
        :name,
        # :complete,
        :flags,
        :note,
        :timeEffort # Where does it start and how long does it take
        
      def id
        parent = @parent
        id = @localId
        while parent != nil
          id = parent.localId + '.' + id
          parent = parent.parent
        end
        id
      end
      def initialize (localId, name, parent = nil, children = [], flags = [], note = nil)
        @name = name
        @localId = localId
        @note = note
        @parent = parent
        @children = children
        @flags = flags
      end
    end
  end
end