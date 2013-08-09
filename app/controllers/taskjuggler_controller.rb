class TaskjugglerController < ApplicationController
  unloadable

  def export
  end

  def import

  end

  def index
    @projects = Project.find(:all, :conditions => ["status = 1 AND parent_id IS NOT NULL"], :order => ["parent_id, name"] )
    @users = User.find(:all)
  end

  def PutIssuesByCat (issues)
    retvar = {}
    issues.each do |issue|
      if issue.category and issue.category.name
        cat_name = issue.category.name
      else
        cat_name = "no_category"
      end
      if not retvar[cat_name]
        retvar[cat_name] = []
      end
      retvar[cat_name].push(issue)
    end
    return retvar
  end

end
