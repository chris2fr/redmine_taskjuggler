# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/controllers/dates_updates_controller.rb
##
# ActiveRectord Tj3. One such record is created for every
# command-line tj3 execution we run.
class Tj3 < ActiveRecord::Base
  unloadable
  has_one :tjp
  attr_accessible output,
    :error,
    :options
end