class AdminController < ApplicationController
#### uncomment to add authentication
#  http_basic_authenticate_with name:"florian", password:"dtucompute", only: [:index]

  def index
    render layout: 'admin'
  end
end