require 'singleton'

module RedmineTaskjuggler
  class Application
    include Singleton
    attr_reader :version
    
    def initialize
      @version = IO.binread("plugins/redmine_taskjuggler/config/VERSION")
    end

  end
end