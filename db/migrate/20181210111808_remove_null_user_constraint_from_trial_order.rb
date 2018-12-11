class RemoveNullUserConstraintFromTrialOrder < ActiveRecord::Migration[5.1]
  def change
    change_column_null :trial_orders, :user_id, true
  end
end
