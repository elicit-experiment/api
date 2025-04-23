# frozen_string_literal: true

class ClientAppController < ApplicationController
  before_action :only_html, except: [:contact]

  include ActionController::Cookies
  include ActionController::RespondWith
  include ActionController::RequestForgeryProtection
  include ActionController::MimeResponds

  after_action :set_csrf_cookie

  rescue_from ActionController::RoutingError, with: :not_found

  def index
    # TODO this should vary based on the path
    preload_header_assets << { path: api_v1_participant_anonymous_protocols_path(public: true), as: 'fetch' }
    render layout: 'client_app'
  end

  def contact
    contact_params = params.require(:contact).permit(:firstName, :lastName, :email, :notes)

    # TODO: send email.
    # Example for sending email (using Rails built-in mailer):
    # ContactMailer.contact_email(contact_params).deliver_later

    # For now, we'll just respond with success
    begin
      respond_to do |format|
        format.json { render json: { success: true }, status: :ok }
      end
    rescue => e
      respond_to do |format|
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  protected

  def set_csrf_cookie
    cookies['X-CSRF-Token'] = form_authenticity_token
  end

  private

  def only_html
    # Since `index` is used by the root route, we can't impose this constraint at the routing level since
    # the catchall route doesn't seem to go to the catchall route for root.
    raise ActionController::RoutingError, 'not html' unless request.format.html?
  end
end
