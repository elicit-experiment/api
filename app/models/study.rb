class Study < ApplicationRecord
  belongs_to :users, foreign_key: "principal_investigator_user_id"
end
