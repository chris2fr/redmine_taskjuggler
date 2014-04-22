class RedmineTaskjugglerWorkload < ActiveRecord::Base
  unloadable
  belongs_to :users
  attr_accessible :user_id,
    :current_date,
    :interval 

  def get_time_entries
    conditions = 'user_id = '+ @user_id.to_s() + ' AND spent_on > "' + (@current_date - @interval).to_s() + '" AND spent_on < "' + (@current_date + @interval).to_s() + '"'
    TimeEntry.find(:all,:conditions => [conditions], :order => ['issue_id,spent_on'] )
  end
  
end
