module RedmineTaskjuggler
  class TJP
    attr_accessor :file_path,
      :project,
      :resources,
      :flags,
      :tasks,
      :bookings
    def initialize (project, resources, tasks, flags = [], bookings = [])
      @project = project
      @resources = resources
      @tasks = tasks
      @flags = flags
      @bookings = bookings
    end
    def to_s
      tjpString = @project.toTJP
      @resources.each {|res|
        tjpString += res.toTJP.gsub(/^/,"  ") + "\n"
      }
      if @flags != []
        tjpString += "flags "
        @flags.each {|flag|
          tjpString += flag + ", "
        }
        tjpString = tjpString[0,-2] + "\n"
      end
      @tasks.each {|task|
        tjpString += task.toTJP  + "\n"
      }
      if @bookings.size > 0
        @bookings.each {|book|
          tjpString += book.toTJP.gsub(/^/,"  ") + "\n"
        }
      end
      tjpString
    end
  end
end