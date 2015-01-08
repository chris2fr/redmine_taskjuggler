# encoding: utf-8
require 'singleton'
##
# The main RedmineTaskjuggler module. This is our out-of-redmine workspace.
module RedmineTaskjuggler
  ##
  # The conventional Application object for plugins
  class Application
    include Singleton
    ##
    # The version of the application
    attr_reader :version
    ##
    # Constructor with a little extra version finding
    def initialize
      @version = IO.binread("plugins/redmine_taskjuggler/config/VERSION")
    end

  end
end
