require 'singleton'

module RedmineWorkload
  class Application
    include Singleton
    attr_reader :version
    
    def initialize
      @version = "0.1.master" # IO.binread("plugins/redmine_taskjuggler/config/VERSION")
    end

  end
end