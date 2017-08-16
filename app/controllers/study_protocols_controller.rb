class StudyProtocolsController < ApplicationController
  before_action :set_study_protocol, only: [:edit, :update, :destroy]

  # GET /study_protocols
  # GET /study_protocols.json
  def index
    @study_protocols = ProtocolsStudy.all
    render json: @study_protocols
  end

  # GET /study_protocols/1
  # GET /study_protocols/1.json
  def show
    @study_protocols = StudyProtocol.where({:study_id => params[:study_id]})
    render json: @study_protocol.errors
  end

  # GET /study_protocols/new
  def new
  end

  # GET /study_protocols/1/edit
  def edit
  end

  # POST /study_protocols
  # POST /study_protocols.json
  def create
#    puts ActiveRecord::Base.connection.tables
    safe_params = params.require(:study_id)
    p = { :study_id => params[:study_id],
          :protocol_id => 0,
          :sequence_no => params[:sequence_no] }
    @study_protocol = ProtocolsStudy.new(params.permit(:study_id, :protocol_id, :sequence_no))

    respond_to do |format|
      if @study_protocol.save
        format.html { redirect_to @study_protocol, notice: 'Study protocol was successfully created.' }
        format.json { render json: @study_protocol.to_json, status: :created }
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
      params.require(:study_id).permit(:protocol_id, :sequence_no)
    end
end
