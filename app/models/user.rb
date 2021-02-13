# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :doorkeeper

  ROLES = { admin: 'admin', investigator: 'investigator', registered: 'registered_user', anonymous: 'anonymous_user' }.freeze

  validates :role, acceptance: { accept: ROLES.values }

  has_many :study_definitions

  # This was poorly-named; we already have a role for anonymous.
  # TODO: change the name in the DB and clean up
  alias_attribute :auto_created, :anonymous

  def serializable_hash(options = {})
    options[:methods] ||= []
    options[:methods] += [:auto_created]
    options[:except] ||= []
    options[:except] += [:anonymous]
    super options
  end

  class << self
    def authenticate(email, password)
      user = User.find_for_authentication(email: email)
      user = User.find_for_authentication(username: email) if user.nil?
      user.try(:valid_password?, password) ? user : nil
    end
  end

  ROLES.keys.each do |attribute|
    define_method :"is_#{attribute}?" do
      ROLES[attribute] == role
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
    key :required, %i[email password password_confirmation]
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
    property :auto_created do
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
