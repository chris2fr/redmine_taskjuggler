# encoding: utf-8
##
#
require File.expand_path('../../test_helper', __FILE__)
#ActionController::TestCase.send :include, Redmine::PluginFixturesLoader

class TjTeamTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true
  #plugin_fixtures :tj_teams
  #ActiveRecord::Fixtures.create_fixtures(File.expand_path('../../fixtures', __FILE__), :tj_teams)
  #fixtures :projects,
  #         :users,
  #         :roles,
  #         :members,
  #         :member_roles,
  #         :issues,
  #         :issue_statuses,
  #         :versions,
  #         :trackers,
  #         :projects_trackers
  #ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
  #                          [:tj_teams]
  #)

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  test "a team has a name" do
    
    tjt = @tj_teams['redwhite_team']
    assert tjt.name == "RedWhite Team"
    
  end
  
end
