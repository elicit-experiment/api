class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :doorkeeper
  validates :role, acceptance: { accept: ['admin', 'registered_user', 'anonymous_user'] }

  class << self
     def authenticate(email, password)
       user = User.find_for_authentication(email: email)
       user.try(:valid_password?, password) ? user : nil
     end
  end
end
