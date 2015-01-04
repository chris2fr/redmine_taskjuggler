# encoding: utf-8
require 'singleton'

module RedmineWorkload
  ##
  # The conventional Application object, as if there are many.
  class Application
    include Singleton
    ##
    # conventional, but I read it from a file
    attr_reader :version
    
    def initialize
      @version = IO.binread("plugins/redmine_taskjuggler/config/VERSION")
    end

  end
end