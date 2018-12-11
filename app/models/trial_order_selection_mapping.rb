class TrialOrderSelectionMapping < ApplicationRecord
  belongs_to :trial_order
  belongs_to :user
  belongs_to :phase_definition
end
