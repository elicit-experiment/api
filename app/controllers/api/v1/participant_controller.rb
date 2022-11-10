# frozen_string_literal: true

module Api
  module V1
    class ParticipantController < ApiController
      before_action :doorkeeper_authorize!, except: %i[anonymous_protocols anonymous_protocol] # Requires access token for all actions

      def eligeable_protocols
        @public = params[:public] == 'true'
        @protocol_users = ProtocolUser
                          .joins(:protocol_definition)
                          .joins(:study_definition)
                          .merge(ProtocolDefinition.where(active: true))
                          .left_outer_joins(:experiment)
                          .where({ user_id: current_api_user_id })
                          .order(created_at: :desc)


        @protocol_users = @protocol_users.where({ study_definitions: { show_in_study_list: true } }) if @public
        @protocol_users = @protocol_users.includes([:study_definition, { experiment: :current_stage }])

        respond_with @protocol_users, include: [:protocol_definition, :study_definition, { experiment: { include: :current_stage } }]
      end

      def anonymous_protocols
        @public = params[:public] == 'true'

        study_definition_filter                      = { allow_anonymous_users: true }

        study_definition_filter[:show_in_study_list] = true if @public

        @protocol_definitions = ProtocolDefinition
                                .joins(:study_definition)
                                .where({
                                         active: true,
                                         study_definitions: study_definition_filter
                                       })
                                .order(created_at: :desc)

        expires_in 5.seconds, must_revalidate: false

        if stale? @protocol_definitions
          # respond_with @protocol_definitions, :include => [:study_definition]
        else
          Rails.logger.info '!STALE'
        end
      end

      def anonymous_protocol
        @public = params[:public] == 'true'
        @id = params[:id]

        study_definition_filter = { allow_anonymous_users: true }

        @protocol_definitions = ProtocolDefinition
                                .joins(:study_definition)
                                .where({
                                         id: @id,
                                         active: true,
                                         study_definitions: study_definition_filter
                                       })

        respond_with @protocol_definitions, include: [:study_definition]
      end
    end
  end
end
