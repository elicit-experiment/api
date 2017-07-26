class User < ApplicationRecord
  validates :role, acceptance: { accept: ['admin', 'registered_user', 'anonymous_user'] }
end
