module ChaosApi
  module V6
    class BaseChaosController < ApplicationController
      class UnknownSession < StandardError; end

      rescue_from UnknownSession, with: :unknown_session

      def load_chaos_session_guid
        referrer = request.referer
        Rails.logger.debug "Referer: #{referrer}"
        Rails.logger.debug cookies: request.cookies
        session_guids = {}
        if referrer.present?
          qp = Rack::Utils.parse_nested_query URI(referrer).query
          session_guids[:referrer] = qp['session_guid']
        end
        session_guids[:cookie] = request.cookies['session_guid']
        session_guids[:query_param] = params[:sessionGUID]
        session_guids[:path] = params[:session_guid]
        @session_guid = session_guids.values.reject(&:blank?).first

        Rails.logger.info("#{session_guids.ai} -> #{@session_guid}")

        @session_guid
      end

      def require_chaos_session

        if @session_guid.blank? || (@chaos_session = Chaos::ChaosSession.where(session_guid: @session_guid).first).nil?
          raise UnknownSession, 'Unknown session'
        end

      end

      def unknown_session(exception)
        @response = ChaosResponse.new(nil, exception.message)
        render json: @response.to_json, status: :unprocessable_entity
      end
    end
  end
end