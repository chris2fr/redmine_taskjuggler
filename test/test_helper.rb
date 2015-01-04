# encoding: utf-8
## Load the normal Rails helper
#require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
#
## Ensure that we are using the temporary fixture path
#Engines::Testing.set_fixture_path

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')


#ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
#                                       [:tj_teams])

#
## From : http://www.redmine.org/boards/3/topics/35164
#module Redmine
#  ##
#  # use the plugin_fixtures the same way you use fixtures.
#  # From : http://www.redmine.org/boards/3/topics/35164
#  module PluginFixturesLoader
#    def self.included(base)
#      base.class_eval do
#        def self.plugin_fixtures(*symbols)
#          ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures/', symbols)
#        end
#      end
#    end
#  end
#end
###
## From : http://www.redmine.org/boards/3/topics/35164
#unless ActionController::TestCase.included_modules.include?(Redmine::PluginFixturesLoader)
#  ActionController::TestCase.send :include, Redmine::PluginFixturesLoader
#end






#require 'simplecov'
#require 'simplecov-rcov'
#SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
#SimpleCov.start 'rails' if ENV["COVERAGE"]

# For factory_girl_rails tests
# require File.expand_path(File.dirname(__FILE__) + '/factories')