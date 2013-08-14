module RedmineTaskjuggler
  module RedminePatch
    module Project
      attr_accessor :tjVersion,
        :tjDailyWorkingHours,
        :tjPeriod,
        :tjCurrency,
        :tjNow,
        :tjNumberFormat,
        :tjTimingResolution,
        :tjTimeFormat
    end
    module TJVacation
      attr_accessor :period,
        :titre
    end
    module TJSettings
      attr_accessor :tjVacations,
        :tjFlags
    end
    module User
      attr_accessor :tjParent,
        :tjRate,
        :tjVacations,
        :tjLimits
    end
    module Issue
      attr_accessor :tjDepends,
        :tjPreceedes,
        :tjParent,
        :tjScheduled,
        :tjAllocates, # Users
        :tjLimits
      class TJIssueRelationship
        attr_accessor :issue_id,
          :gap_number,
          :gap_units,
          :gap_type # length or duration
      end
    end
    module IssuePriority
      attr_accessor :tjPriority1000
    end
    module TimeEntry
      attr_accessor :startTime
    end
  end
end