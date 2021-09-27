# frozen_string_literal: true

module Api
  module V1
    class ProtocolDefinitionsController < ApiController
      include StudyCreation

      skip_before_action :authenticate_user!, only: :take

      before_action :doorkeeper_authorize!, except: [:take] # Requires access token for all actions except take, which can be anonymous

      def take
        @study_definition_id = params[:study_definition_id]
        @protocol_definition_id = params[:protocol_definition_id]

        set_protocol_user

        return if performed?

        unless @protocol_user
          render json: ElicitError.new('Cannot find user for protocol.', :unauthorized), status: :unauthorized unless performed?
          return
        end

        unless @protocol_user.protocol_definition.active
          render json: ElicitError.new("Cannot take protocol that isn't active.", :bad_request), status: :bad_request
          return
        end

        session_guid = SecureRandom.uuid
        query_params = { session_guid: session_guid }.merge(request.query_parameters)
        query_string = '?' + query_params.map { |k, v| "#{k}=#{v}" }.join('&')
        hash_string = "#Experiment/#{@protocol_definition_id}"

        pfe = Rails.configuration.elicit[:participant_frontend]
        session_params = {
          user_id: @protocol_user.user_id,
          session_guid: session_guid,
          url: "#{pfe[:scheme]}://#{pfe[:host]}:#{pfe[:port]}/#{query_string}#{hash_string}",
          expires_at: Date.today + 1.day,
          study_definition_id: @study_definition_id,
          protocol_definition_id: @protocol_definition_id,
          protocol_user_id: @protocol_user.id
        }
        session = Chaos::ChaosSession.new(session_params)

        session.populate request.query_parameters

        Rails.logger.info "Taking session #{session.ai}"

        if session.save
          respond_with session
        else
          logger.error session.errors.ai
          render json: ElicitError.new('Failed to create session', :unprocessable_entity), status: :unprocessable_entity
        end
      end

      def set_protocol_user
        if current_api_user_id
          @protocol_user = ProtocolUser.for_user(@protocol_definition_id, current_api_user_id).first!
          return
        end

        study_definition = StudyDefinition.find(@study_definition_id)

        return nil unless study_definition

        return nil unless study_definition.allow_anonymous_users

        worker_id = params[:workerId]

        Rails.logger.info "WORKERID: #{worker_id}"

        unless worker_id.blank? || !/[A-Z0-9]+/.match(worker_id)
          Rails.logger.info "Not logged in during take, but workerId specified as #{worker_id}; trying anonymous protocol."

          user = create_and_sign_in_anonymous_participant(study_definition, worker_id, 'mturk.elicit.com')

          return unless user

          protocol_user = ProtocolUser.find_or_create_by(protocol_definition_id: @protocol_definition_id, user_id: user.id, group_name: 'MTurkAnonymous')

          @protocol_user = protocol_user if protocol_user.save

          return
        end

        Rails.logger.info 'Not logged in during take; trying anonymous protocol by stealing a predefined ProtocolUser...'

        candidate_protocol_users = ProtocolUser.free_for_anonymous(@protocol_definition_id)

        Rails.logger.info candidate_protocol_users.explain

        Rails.logger.info "Anonymous protocol. Got #{candidate_protocol_users.size} candidates."

        @protocol_user = candidate_protocol_users.take

        render json: ElicitError.new('Maximum participant exceeded.', :gone), status: :ok unless performed? || @protocol_user
      end

      private

      def create_and_sign_in_anonymous_participant(study_definition, username, email_domain = 'elicit.com')
        user_params = { email: "#{username}@#{email_domain}".downcase, username: username, role: User::ROLES[:anonymous] }

        user = User.find_or_initialize_by(user_params) do |user|
          Rails.logger.info "Trying to create new anonymous user #{username}"
          user.password = 'abcd12_'
          user.password_confirmation = 'abcd12_'
          user.sign_in_count = 0
          user.auto_created = true

          StudyDefinition.transaction do
            study_definition.reload
            if study_definition.auto_created_user_count < study_definition.max_auto_created_users
              if user.save
                study_definition.increment!(:auto_created_user_count)
                Rails.logger.info "Created anonymous user #{username} id=#{user.id}"
              else
                Rails.logger.warn "User failed to save #{user.errors.ai}"
                user = nil
              end
            else
              Rails.logger.warn "No budget remains for creating anonymous user: #{study_definition.auto_created_user_count}/#{study_definition.max_auto_created_users} taken"
              user = nil
              render json: ElicitError.new('Maximum participant exceeded.', :not_found), status: :unauthorized unless performed?
            end
          end
          user
        end

        if user
          Rails.logger.info "Signing in anonymous user #{username} #{user.ai}."

          sign_in(:user, user)
        else
          Rails.logger.warn 'No suitable user found/created in create_and_sign_in_anonymous_participant'
        end

        user
      end

      def query_params
        { study_definition_id: params[:study_definition_id] }
      end

      def query_includes
        { phase_definitions: :trial_definitions }
      end

      def response_includes
        { phase_definitions: { include: :trial_definitions } }
      end

      def protocol_definition_params
        params.require(:study_definition_id)
        permit_json_params(params[:protocol_definition], :protocol_definition) do
          params.require(:protocol_definition).permit(%i[definition_data type name summary description active])
                .merge(study_definition_id: params[:study_definition_id])
        end
      end
    end
  end
end
