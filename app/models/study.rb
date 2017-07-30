class Study < ApplicationRecord
  belongs_to :user, foreign_key: "principal_investigator_user_id"
end
