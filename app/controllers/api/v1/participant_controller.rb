module Api::V1
  class ParticipantController < ApiController
    before_action :doorkeeper_authorize!, except: [:anonymous_protocols] # Requires access token for all actions

    def eligeable_protocols
      @public = params[:public] == 'true'
      @protocol_users = ProtocolUser
                          .joins(:protocol_definition)
                          .joins(:study_definition)
                          .merge(ProtocolDefinition.where(:active => true))
                          .left_outer_joins(:experiment)
                          .where({ :user_id => current_api_user_id })

      @protocol_users = @protocol_users.where({ study_definitions: {show_in_study_list: true} }) if @public
      @protocol_users = @protocol_users.includes([:study_definition, { :experiment => :current_stage }])

      respond_with @protocol_users, :include => [:protocol_definition, :study_definition, { :experiment => { include: :current_stage } }]
    end

    def anonymous_protocols
      @public = params[:public] == 'true'

      study_definition_filter                      = { :allow_anonymous_users => true }

      study_definition_filter[:show_in_study_list] = true if @public

      @protocol_definitions = ProtocolDefinition
                                .joins(:study_definition)
                                .where({
                                         active:            true,
                                         study_definitions: study_definition_filter
                                       }
                                )

      respond_with @protocol_definitions, :include => [:study_definition]
    end

    private

  end
end
