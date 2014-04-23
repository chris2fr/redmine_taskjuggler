# encoding: utf-8
##
# A single-level user-exclusive team concept for Task-Juggler
class TjTeam < ActiveRecord::Base
  unloadable
  has_many :users
  attr_accessible :name
  
  ##
  # FIXME: generates a task-juggler safe identifier
  def code_name
    #@name.downcase.gsub(" ","_").gsub("-","_")
    # puts "\n\n   ========> name : " + @name.to_s
    # puts "\n\n   ========> name : " + @name.to_s
    #"default_team"
  end
end
