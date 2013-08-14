require_dependency 'time_entry'
#
# Represents a Redmine TimeEntry mapped to a Taskjuggler Booking
#
class RedTimeEntry < ActiveRecord::Base
  unloadable
  #code
end