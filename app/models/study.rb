class Study < ApplicationRecord
  has_one :user, foreign_key: "principal_investigator_user_id"
end
