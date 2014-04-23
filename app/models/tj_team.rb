# encoding: utf-8
##
# A single-level user-exclusive team concept for Task-Juggler
class TjTeam < ActiveRecord::Base
  unloadable
  has_many :users
end
