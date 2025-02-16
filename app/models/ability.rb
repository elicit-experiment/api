# frozen_string_literal: true

# Cancancan abilities for Elicit
class Ability
  include CanCan::Ability

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

    # `:read_study_results` works in consort with `StudyResultConcern` . All actions that are children of study_results will get
    # authorized by loading the study result in params[:study_result_id]. `StudyResult::StudyResult` will get authorized by the
    # common `authorize!` of `get_resource`, which will load the `StudyResult` based on `params[:id]` for that particular controller.
    # We do this because the params are different for the top route `resource` in the route hierarchy (`:id` for the top, `:study_result_id` elsewhere)
    # Thus everything in the model hierarchy for a given result is authorized based on the study result.
    can :read_study_results, StudyResult::StudyResult do |study_result|
      study_result.study_definition.principal_investigator_user_id == user.id
    end

    all_study_result_classes.each do |study_result_class|
      can :read_study_results, StudyResult.const_get(study_result_class)
    end
  end

  def all_study_result_classes
    @all_study_result_classes ||= ::StudyResult.constants.reject { |c| c == :StudyResult }
  end
end
