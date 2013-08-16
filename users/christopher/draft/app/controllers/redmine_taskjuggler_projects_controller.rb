require_dependency 'project' 
require_dependency '../models/red_task_project'

class RedmineTaskjugglerProjectsController < ApplicationController
  unloadable
  #include redmine_taskjuggler

  # GET /redmine_taskjuggler_projects
  # GET /redmine_taskjuggler_projects.json
  def index
    @redmine_taskjuggler_projects = RedTaskProject.all
  end

  # GET /redmine_taskjuggler_projects/1
  # GET /redmine_taskjuggler_projects/1.json
  def show
    @redmine_taskjuggler_project =
    if RedTaskProject.exists?(params[:id])
      @redmine_taskjuggler_project = RedTaskProject.find(params[:id])
    else
      project = Project.find('test')
      @redmine_taskjuggler_project = RedTaskProject.find(project.id)
    end
  end

  # GET /redmine_taskjuggler_projects/new
  def new
    @redmine_taskjuggler_project = RedTaskProject.new
  end

  # GET /redmine_taskjuggler_projects/1/edit
  def edit
    @redmine_taskjuggler_project = RedTaskProject.find(params[:id])
  end

  # POST /redmine_taskjuggler_projects
  # POST /redmine_taskjuggler_projects.json
  def create
    @redmine_taskjuggler_project = RedTaskProject.new(redmine_taskjuggler_project_params)    

    respond_to do |format|
      if @redmine_taskjuggler_project.save
        format.html { redirect_to @redmine_taskjuggler_project, notice: 'Redmine taskjuggler project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @redmine_taskjuggler_project }
      else
        format.html { render action: 'new' }
        format.json { render json: @redmine_taskjuggler_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /redmine_taskjuggler_projects/1
  # PATCH/PUT /redmine_taskjuggler_projects/1.json
  def update
    @redmine_taskjuggler_project = RedTaskProject.find(params[:id])
    respond_to do |format|
      if @redmine_taskjuggler_project.update_attributes(redmine_taskjuggler_project_params)
        format.html { redirect_to @redmine_taskjuggler_project, notice: 'Redmine taskjuggler project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @redmine_taskjuggler_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redmine_taskjuggler_projects/1
  # DELETE /redmine_taskjuggler_projects/1.json
  def destroy
    @redmine_taskjuggler_project = RedTaskProject.find(params[:id])
    @redmine_taskjuggler_project.destroy
    respond_to do |format|
      format.html { redirect_to redmine_taskjuggler_projects_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_redmine_taskjuggler_project
      @redmine_taskjuggler_project = RedTaskProject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def redmine_taskjuggler_project_params
      # params.require(:redmine_taskjuggler_project).permit(:project, :active, :roottask, :start_date, :end_date, :dailyworkinghours, :timeformat)
      params['redmine_taskjuggler_project']
    end

end
