class StudyProtocolsController < ApplicationController
  before_action :set_study_protocol, only: [:show, :edit, :update, :destroy]

  # GET /study_protocols
  # GET /study_protocols.json
  def index
    @study_protocols = StudyProtocol.all
  end

  # GET /study_protocols/1
  # GET /study_protocols/1.json
  def show
  end

  # GET /study_protocols/new
  def new
    @study_protocol = StudyProtocol.new
  end

  # GET /study_protocols/1/edit
  def edit
  end

  # POST /study_protocols
  # POST /study_protocols.json
  def create
    @study_protocol = StudyProtocol.new(study_protocol_params)

    respond_to do |format|
      if @study_protocol.save
        format.html { redirect_to @study_protocol, notice: 'Study protocol was successfully created.' }
        format.json { render :show, status: :created, location: @study_protocol }
      else
        format.html { render :new }
        format.json { render json: @study_protocol.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /study_protocols/1
  # PATCH/PUT /study_protocols/1.json
  def update
    respond_to do |format|
      if @study_protocol.update(study_protocol_params)
        format.html { redirect_to @study_protocol, notice: 'Study protocol was successfully updated.' }
        format.json { render :show, status: :ok, location: @study_protocol }
      else
        format.html { render :edit }
        format.json { render json: @study_protocol.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /study_protocols/1
  # DELETE /study_protocols/1.json
  def destroy
    @study_protocol.destroy
    respond_to do |format|
      format.html { redirect_to study_protocols_url, notice: 'Study protocol was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study_protocol
      @study_protocol = StudyProtocol.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_protocol_params
      params.require(:study_protocol).permit(:belongs_to, :belongs_to)
    end
end
