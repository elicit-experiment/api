# frozen_string_literal: true

class ClientAppController < ApplicationController
  before_action :only_html

  def index
    # TODO this should vary based on the path
    preload_header_assets << { path: api_v1_participant_anonymous_protocols_path(public: true), as: 'fetch' }
    render layout: 'client_app'
  end

  private

  def only_html
    return if request.format.html?

    not_found
  end

  def not_found
    head :not_found
  end
end
