# frozen_string_literal: true

# Cancancan abilities for Elicit
class Ability
  include CanCan::Ability

  STUDY_RESULT_ACTIONS = %i[
    read_study_results
    create_study_results
    update_study_results
    destroy_study_results
  ].freeze

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    return if user.blank?

    Rails.logger.info message: 'AUTH', user: user.attributes

    if [User::ROLES[:admin]].include?(user.role)
      can :upgrade, User
      can :create_admin, User
      can :create_investigator, User
      can :create_standard, User
      can :manage, :all
      can :read, :all
      can :read_study_results, :all
      can :read_study_definitions, :all
      can :create_studies, :all

      return
    end

    return unless [User::ROLES[:investigator]].include?(user.role)

    can :read, User
    can :create_standard, User
    can :create_studies, :all
    can :read_study_definitions, StudyDefinition do |study_definition|
      study_definition.principal_investigator_user_id == user.id
    end

    # Every study result action is authorized against the parent
    # StudyResult::StudyResult, including reads of its child results. Hash
    # conditions (rather than a block) keep the rule usable with
    # `accessible_by`, which is how top-level collections are restricted to
    # permitted studies.
    can STUDY_RESULT_ACTIONS, StudyResult::StudyResult,
        study_definition: { principal_investigator_user_id: user.id }
  end
end
