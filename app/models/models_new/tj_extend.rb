# encoding:utf-8:noai:expandtab:ts=2:sw=2
##
# RedmineTaskjuggler (c) Christopher Mann et al. 2009 - 2014
# Licence GPL v3.0 Affero
# https://github.com/chris2fr/redmine_taskjuggler/
# File : app/models/tj_extend.rb
##
# The Extending of a Resource or Task within the Project declaration in TaskJuggler
class TjExtend < ActiveRecord::Base
  unloadable
  ##
  # The type of extension such as text
  attr_accessor :vartype
  ##
  # Machine usable identifier
  attr_accessor :code
  ##
  # Human-readable describtive name
  attr_accessor :name
  ##
  # TaskJuggler compatible template for hashtable
  def template
    @template ||
    <<-EOS
      %{type} %{code} "%{name}"
    EOS
  end
  ##
  # To produce a hashtable
  def to_hashtable
    {
      type: type,
      code: code,
      name: name
    }
  end
  ##
  # TaskJuggler compatible string
  def to_s
    template % to_hashtable
  end
end

##
# Extension of resource attributes
class TjExtendResounce < TjExtend
end
##
# Extension of task attributes
class TjExtendTask < TjExtend
end
