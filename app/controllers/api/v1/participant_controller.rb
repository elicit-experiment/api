module Api::V1
  class ParticipantController < ApiController

    def eligeable_protocols
      protocol_users = ProtocolUser.left_outer_joins(:experiment).where({:user_id => current_user.id}).includes([:protocol_definition, :study_definition, {:experiment => :current_stage}])

      respond_with protocol_users, :include => [:protocol_definition, :study_definition, { :experiment => {include: :current_stage} }  ]
    end

   private

  end
end
