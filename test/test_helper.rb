# encoding: utf-8
## Load the normal Rails helper
#require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
#
## Ensure that we are using the temporary fixture path
#Engines::Testing.set_fixture_path

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

#require 'simplecov'
#require 'simplecov-rcov'
#SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
#SimpleCov.start 'rails' if ENV["COVERAGE"]

# For factory_girl_rails tests
# require File.expand_path(File.dirname(__FILE__) + '/factories')