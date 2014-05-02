# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : lib/tjp.rb
require 'tempfile'
##
# Taskjuggler Tjp File
class RedmineTaskjuggler::Taskjuggler::Tjp
  ##
  # Tjp A TJP File Representation
  attr_accessor :filename
  ##
  # A temp file
  attr_accessor :tmpfile
  ##
  # Constructure with one option filename:
  def initialize (opts={})
    defaults = {filename: false}
    opts = defaults.merge(opts)
    @filename = opts[:filename]
    @tmpfile = Tempfile.new(@filename)
  end
  ##
  # Reads the contents of the TJP File
  def read
    return @tmpfile.read
  end
  ##
  # Writes the contents of the TJP File
  def write (str)
    @tmpfile.write(str)
  end
  
end