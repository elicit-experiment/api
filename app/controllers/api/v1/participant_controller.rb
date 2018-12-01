module Api::V1
  class ParticipantController < ApiController
    before_action :doorkeeper_authorize! # Requires access token for all actions

    def eligeable_protocols
      protocol_users = ProtocolUser.joins(:protocol_definition)
                                   .merge(ProtocolDefinition.where(:active => true))
                                   .left_outer_joins(:experiment)
                                   .where({:user_id => current_api_user_id})
                                   .includes([:study_definition, {:experiment => :current_stage}])

      respond_with protocol_users, :include => [:protocol_definition, :study_definition, { :experiment => {include: :current_stage} }  ]
    end

   private

  end
end
