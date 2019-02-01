class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :doorkeeper

  ROLES={:admin => 'admin', :registered => 'registered_user', :anonymous => 'anonymous_user'}

  validates :role, acceptance: { accept: ROLES.values() }

  has_many :study_definitions

  class << self
     def authenticate(email, password)
       user = User.find_for_authentication(email: email)
       user = User.find_for_authentication(username: email) if user.nil?
       user.try(:valid_password?, password) ? user : nil
     end
  end

  include Swagger::Blocks

  swagger_schema :User do
    key :required, [:email]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :email do
      key :type, :string
    end
    property :username do
      key :type, :string
    end
#    property :role do
#      key :enum, User::ROLES.values
#    end
    property :role do
      key :type, :string
    end
    property :anonymous do
      key :type, :boolean
    end
    property :password do
      key :type, :string
      key :example, 'specify password'
    end
    property :password_confirmation do
      key :type, :string
    end
  end

  swagger_schema :UserDefinition do
    key :required, [:email, :password, :password_confirmation]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :email do
      key :type, :string
    end
    property :username do
      key :type, :string
    end
#    property :role do
#      key :enum, User::ROLES.values
#    end
    property :role do
      key :type, :string
    end
    property :anonymous do
      key :type, :boolean
    end
    property :password do
      key :type, :string
      key :example, 'specify password'
    end
    property :password_confirmation do
      key :type, :string
    end
  end

end
