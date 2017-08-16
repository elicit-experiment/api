class StudiesController < ApplicationController
  before_action :set_study, only: [:show, :edit, :update, :destroy]

  # GET /studys
  # GET /studys.json
  def index
    @studies = Study.all

    render json: @studies
  end

  # GET /studys/1
  # GET /studys/1.json
  def show
  end

  # GET /studys/new
  def new
    @study = Study.new
  end

  # GET /studys/1/edit
  def edit
  end

  # POST /studys
  # POST /studys.json
  def create
    x = params.permit(:title, :principal_investigator_user_id)
    @study = Study.new(x)

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

    respond_to do |format|
      if @study.update(study_params)
        format.html { redirect_to @study, notice: 'Study was successfully updated.' }
        format.json { render json: @study.to_json, status: :ok, location: @study }
      else
        format.html { render :edit }
        format.json { render json: @study.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /studys/1
  # DELETE /studys/1.json
  def destroy
    @study.destroy
    @study.save!
    respond_to do |format|
#      format.html { redirect_to studys_url, notice: 'Study was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study
      @study = Study.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_params
      params.require(:study).permit(:name, :email, :anonymous, :role)
    end
end
