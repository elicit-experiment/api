module ChaosApi::V6
  class SlideController < ApplicationController
    #### uncomment to add authentication
    #  http_basic_authenticate_with name:"florian", password:"dtucompute", only: [:index]
    before_action :cors_preflight_check
    after_action :cors_set_access_control_headers

    def get
      ap params
      @questionnaireId = params[:questionaireId]
      @slideIndex = params[:slideIndex]
      @response = ChaosResponse.new([])

      respond_to do |format|
        format.xml { render :xml => '' }
        format.json { render :json => @response.to_json }
      end
    end

    private

    def post_params
      #validate POST parameters
      params.require(:experiment).permit(:author_id, :name)
    end
  end
end
