class TrialOrderSelectionMapping < ApplicationRecord
  belongs_to :trial_order, :foreign_key => "trial_order_id"
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :phase_definition, :foreign_key => "phase_definition_id"
end
