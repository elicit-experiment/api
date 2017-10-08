module Chaos
  class ChaosSession < ApplicationRecord
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  end
end
