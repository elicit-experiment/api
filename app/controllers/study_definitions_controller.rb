class StudyDefinitionsController < ApplicationController
  before_action :set_study, only: [:show, :edit, :update, :destroy]

#  before_action :authenticate_user!
  before_action :doorkeeper_authorize!

  # GET /studys
  # GET /studys.json
  def index
    @studies = StudyDefinition.all

    render json: @studies
  end

  # GET /studys/1
  # GET /studys/1.json
  def show
  end

  # GET /studys/new
  def new
    @study = StudyDefinition.new
  end

  # GET /studys/1/edit
  def edit
  end

  # POST /studys
  # POST /studys.json
  def create
    x = params.permit(:title, :principal_investigator_user_id)
    @study = StudyDefinition.new(x)

    if @study.save
      render json: @study.to_json, status: :created
    else
      render json: @study.errors, status: :unprocessable_entity 
    end
  end

  # PATCH/PUT /studys/1
  # PATCH/PUT /studys/1.json
  def update
    study_params = params.permit(:title, :principal_investigator_user_id)

    if @study.update(study_params)
      render json: @study.to_json, status: :ok, location: @study
    else
      render json: @study.errors, status: :unprocessable_entity
    end
  end

  # DELETE /studys/1
  # DELETE /studys/1.json
  def destroy
    @study.destroy
    @study.save!
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study
      @study = StudyDefinition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_params
      params.require(:study).permit(:name, :email, :anonymous, :role)
    end
end
