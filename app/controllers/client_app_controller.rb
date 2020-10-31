# frozen_string_literal: true

class ClientAppController < ApplicationController
  def index
    render layout: 'client_app'
  end
end
