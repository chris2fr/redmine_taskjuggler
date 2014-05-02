# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : lib/tj3.rb

##
# Taskjuggler Tj3 Command-Line Execution Library
class RedmineTaskjuggler::Taskjuggler::Tj3
  ##
  # Tjp A TJP File Representation
  attr_accessor :tjp
  ##
  # The resulting dates file
  attr_accessor :report_task_dates_csv
  ##
  # string the command line argument
  attr_accessor :cmd
  ##
  # String the exectuion output std_out
  attr_accessor :output
  ##
  # String the execution error std_error
  attr_accessor :error
  ###
  ## file descriptor of the status of execution
  #attr_accessor :status
  ##
  # array? options used when compiling
  attr_accessor :options
  
  ##
  # Constructor
  def initialize (opts={})

    defaults = {tjp: nil,
      report_task_dates_csv: nil,
      cmd: "tj3"
      }
    opts = defaults.merge(opts)
    @filename = opts[:filename]
    
    self.cmd = opts[:cmd]
    self.tjp = opts[:tjp]
    self.tjp ||= Tjp.new()
    self.report_task_dates_csv = opts[:report_task_dates_csv]
  end
  
  ##
  # runs tj3 on the command-line
  def run
    if not @tjp || @cmd
      raise "Must have command and TJP to run"
    end
    #io = IO.popen([@cmd, "#{@tjp.path}#{File::ALT_SEPARATOR}#{@tjp.filename}"])
    
    @output,@error,@status = Open3.capture3("#{@cmd} #{@tjp.path}#{File::ALT_SEPARATOR}#{@tjp.filename}")
    if @status.success?
      @output
    else
      @error
    end
    
  end
  
end