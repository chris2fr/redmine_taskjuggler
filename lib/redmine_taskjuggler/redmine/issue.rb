module RedmineTaskjuggler
  #
  # Abstraction class for Redmine Data Model.
  #
    class Issue
      attr_accessor :id,
        :identifier,
        :subject,
        :start_date,
        :due_date,
        :done_ratio,
        :parent,
        :children,
        :project,
        :description,
        :assigned_to, # User
        :estimated_hours,
        :priority
    end
    class IssuePriority
      
    end
  end
end