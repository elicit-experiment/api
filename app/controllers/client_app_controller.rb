# frozen_string_literal: true

class ClientAppController < ApplicationController
  def index
    preload_header_assets << { path: api_v1_participant_anonymous_protocols_path(public: true), as: 'fetch' }
    render layout: 'client_app'
  end
end
