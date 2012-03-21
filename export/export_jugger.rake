require 'set'

def find_recursive_resources(issues)
  ret = Set.new

  if issues.class.to_s == "Array"
    issues.each do |issue|
      ret << issue.assigned_to if not issue.assigned_to.nil?
      issue.children.each do |subissue|
        ret.union find_recursive_resources(subissue)
      end
    end
  else
    ret << issues.assigned_to if not issues.assigned_to.nil?
  end

  return ret
end

namespace :export do

  desc "Taskjuggler Export"
  task :juggler, [ :arg1 ] => :environment do |task, args|

    arg1 = args['arg1']
    puts "# argument '#{arg1}' given"
    issues = nil
    project_name = nil

    # is the given argument an id? If so, try to find the corresponding issue
    if arg1.to_i.to_s == arg1
      i = Issue.find arg1
      if i.nil?
        puts "Error: Could not find an issue with the given id '#{arg1}'"
        exit 1
      else
        issues = i.children
        project_name = i.subject
      end
    
    # Try to find the project given by the identifier
    else
      p = Project.find_by_identifier arg1
      if p.nil?
        puts "Error: project '#{arg1}' could not be found!"
        exit 1
      else
        issues = p.issues
        project_name = p.name
      end
    end

    puts "project export \"#{project_name}\" 2012-04-08 +2w {\n    timezone \"Europe/Berlin\"\n}"

    # Extract resources from the issues
    resources = find_recursive_resources(issues)

    resources.each do |user|
      puts "resource #{user.login} \"#{user.lastname} #{user.firstname}\" {"
      puts "   email \"#{user.mail}\""
      puts "}"
    end

    # Try to parse the issues
    issues.each do |issue|
      puts "task issue#{issue.id} \"#{issue.subject}\" {"
      if issue.estimated_hours.nil? and issue.children.size == 0
        puts "  # No effort given, try to guess an effort for issue without sub issues"
        puts "  effort 2h"
      else
        puts "  effort #{issue.estimated_hours}h"
      end
      if not issue.start_date.nil?
        puts "  start #{issue.start_date}"
      end
      if issue.relations_to.size > 0
        str = "  depends "
        issue.relations_to.each do |rel|
          str += "!issue#{rel.issue_from_id},"
        end
        puts str[0..-2]
      end
      if not issue.assigned_to.nil?
        puts "  allocate #{issue.assigned_to.login}"
      end
      puts "}"
      puts ""
    end
  end
end
