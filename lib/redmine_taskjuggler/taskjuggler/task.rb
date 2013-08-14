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
      # Returns Taskjuggler TJP representation
      def toTJP
        tjpString = "task #{localId} \"#{name}\" {\n"
        if timeEffort != nil
          tjpString += timeEffort.toTJP.gsub(/^/,"  ") + "\n"
        end
        if localId[0,3] == 'red'
          tjpString += "  Redmine #{localId[3,localId.size]}\n"
        end
        if flags.class == Array and flags != []
          tjpString += "  flags "
          flags.each {|f|
            tjpString += f + ", "
          }
          tjpString = tjpString[0,-2] # Cut off the , at the end
        end
        if note.class == String and note != ""
          tjpString += <<EOS
  note -8<-
#{note.gsub(/\"/,'\\"').gsub(/^/,'  ')}
  ->8-
EOS
        end
        if children.class == Array and children != []
          children.each {|task|
            tjpString += task.toTJP.gsub(/^/,"  ") + "\n"
          }
        end
        tjpString += "}"
        return tjpString
      end
    end
  end
end