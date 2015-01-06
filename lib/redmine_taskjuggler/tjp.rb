#encoding: utf-8

module RedmineTaskjuggler
  ##
  # TJP represents the TJP file for taskjuggler computation
  class TJP
    ##
    # Where the file will be deposited, full path
    attr_accessor :file_path
    ##
    # Project associated
    attr_accessor :project
    ##
    # Array of Resource associated, or perhaps a nested set of Resource ,
    # I am not sure.
    attr_accessor :resources
    ##
    # Array of strings I think
    attr_accessor :flags
    ##
    # Array or nested set of Task
    attr_accessor :task
    ##
    # Array of Booking
    attr_accessor :bookings

    # Builds a TaskJuggler Project file representation
    #  * +project+ Project,
    #  * +resources+ Resource
    #  * +task+ Task
    #  * +flags+ an array of strings
    #  * +bookings+ Booking
    def initialize (project, resources, task, flags = [], bookings = [])
      @project = project
      @resources = resources
      @task = task
      @flags = flags
      @bookings = bookings

      unless @flags.include?('Redmine')
        @flags.push('Redmine', 'RedmineProject', 'RedmineIssue')
      end
    end

    ##
    # Added by Russians for including reports
    # TODO see if we can put this in parameters in Settings as either a text field or file (uploaded) or both
    def incl_file
      out = "\n"
      out << "flags team, hidden\n"
      out << "account cost \"Costs\"\n"
      out << "account rev \"Payments\"\n"
      out << "include \"reports.tji\"\n"
      out << "\n"
    end

    ##
    # Returns Taskjuggler TJP representation
    def to_s
      out = @project.to_tjp + "\n\n"
      team = nil
      @resources.each do |res|
        out << res.to_tjp << "\n"
      end
      unless @flags.empty?
        out << "flags " + flags.join(", ") + "\n"
      end
      out << incl_file
      out << @task.to_tjp << "\n"
      # FIXME shouldn't @bookings be an attribute of task?
      unless @bookings.empty?
        @bookings.each do |book|
          out << book.to_tjp + "\n"
        end
      end
      out << "taskreport redmine_update_issues_csv_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_csv_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {\n"
      out << "  formats csv\n"
      out << "  hidetask ~Redmine\n"
      out << "  columns Redmine, start, end, effort, effortdone, priority\n"
      out << "  balance cost rev\n"
      out << "}\n"
      out << "\n"
      out << "taskreport redmine_update_issues_html_#{@project.id}_#{@project.version.gsub(/\./,'_')} 'redmine_update_issues_html_#{@project.id}_#{@project.version.gsub(/\./,'_')}' {\n"
      out << "  formats html\n"
      out << "  hidetask ~Redmine\n"
      out << "  columns no, name, start, end, effort, effortdone, priority, chart\n"
      out << "  balance cost rev\n"
      out << "}\n"

      return out
    end
  end
end
