# frozen_string_literal: true

class ClientAppController < ApplicationController
  before_action :only_html

  rescue_from ActionController::RoutingError, with: :not_found

  def index
    # TODO this should vary based on the path
    preload_header_assets << { path: api_v1_participant_anonymous_protocols_path(public: true), as: 'fetch' }
    render layout: 'client_app'
  end

  private

  def only_html
    # Since `index` is used by the root route, we can't impose this constraint at the routing level since
    # the catchall route doesn't seem to go to the catchall route for root.
    raise ActionController::RoutingError, 'not html' unless request.format.html?
  end
end
