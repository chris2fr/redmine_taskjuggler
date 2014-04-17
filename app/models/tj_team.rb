class TjTeam < ActiveRecord::Base
  unloadable
  has_many :users
end
