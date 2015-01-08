# encoding: utf-8
##
# Redmine Taskjuggler Temas controller
#
class RedmineTaskjugglerTeamsController < ApplicationController
  unloadable

  def index
    @tj_teams = TjTeam.all
  end

  def new
    @tj_team = TjTeam.create(:name => params[:tj_team_name])
  end

  def create
    @tj_team = TjTeam.create(:name => params[:tj_team_name])
  end

  def show
    @tj_team = TjTeam.find(params[:id])
    @users = User.where(tj_team_id: params[:id])
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
