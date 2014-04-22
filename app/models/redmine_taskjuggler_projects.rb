class RedmineTaskjugglerProjects < ActiveRecord::Base
  unloadable
  belongs_to :projects 
end
