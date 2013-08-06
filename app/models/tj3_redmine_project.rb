#
# Augmenting the project functionality
#
class TJ3Project < Project
  
  has_many :tj3Issues, :as => :issues
  
  # Outputs TJ3 String
  def to_tj3
    
  end
end


class TJ3Issue < Issue
  
  def initialize
    self.extend TJ3Task
    super
  end
  
  def to_tj3
    
  end
  
  # Renders the supplement task part from Redmine journal entries
  def to_tj3_booking
    
  end
  
end
