# frozen_string_literal: true

# Authorizes reads and mutations of study results and their child resources.
#
# The parent StudyResult::StudyResult is the authorization boundary: every
# request is authorized against it, and child records are loaded through its
# associations. A caller therefore cannot combine a study result id they are
# allowed to see with a child id (or parent id) that belongs to another study.
module StudyResultConcern
  extend ActiveSupport::Concern

  AUTHORIZED_ACTIONS = {
    'index' => :read_study_results,
    'show' => :read_study_results,
    'create' => :create_study_results,
    'update' => :update_study_results,
    'destroy' => :destroy_study_results
  }.freeze

  included do
    before_action :authenticate_user!
    before_action :authorize_study_result_request, if: :study_result_request?
    before_action :verify_child_parent, only: %i[create update], if: :nested_under_study_result?

    # A mismatched parent/child id is a legitimate 404. Render it directly:
    # the inherited RecordNotFound handler calls ElicitErrors#not_found, which
    # raises from inside the rescue handler and would surface as a 500.
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  def render_not_found
    head :not_found
  end

  # Authorize against the identity behind the access token. A client-only token
  # has no resource owner and therefore no abilities.
  def current_ability
    @current_ability ||= Ability.new(current_api_user)
  end

  # The authorized parent for nested routes.
  def parent_study_result
    @parent_study_result ||= StudyResult::StudyResult.find(params[:study_result_id])
  end

  # Study results the current user is allowed to read. Used to restrict
  # top-level collections to permitted studies.
  def authorized_study_results
    StudyResult::StudyResult.accessible_by(current_ability, :read_study_results)
  end

  def resource_class
    @resource_class ||= "StudyResult::#{resource_name.classify}".constantize
  end

  def resource_name
    @resource_name ||= controller_name.singularize
  end

  # GET /api/v1/study_results/:study_result_id/{children}
  #
  # Collections are built from the authorized parent association, so a filter
  # parameter can only narrow the parent's results, never widen them.
  def index
    return super unless nested_under_study_result?

    resources = parent_study_result.public_send(resource_name.pluralize)
    filters = query_params&.compact
    resources = resources.where(filters) if filters.present?
    resources = resources.includes(query_includes).order(order_params)
    resources = resources.page(page_params[:page]).per(page_params[:page_size]) unless page_params.nil?

    instance_variable_set("@#{resource_name.pluralize}", resources)
    respond_with instance_variable_get("@#{resource_name.pluralize}"), include: response_includes
    set_pagination_headers instance_variable_get("@#{resource_name.pluralize}")
  end

  private

  # True for the top-level study results collection as well as any nested route.
  def study_result_request?
    params[:study_result_id].present? || resource_name == 'study_result'
  end

  def nested_under_study_result?
    params[:study_result_id].present? && resource_name != 'study_result'
  end

  # Nested resources are loaded through the authorized parent, so a mismatched
  # parent/child id pair resolves to 404 instead of another study's record.
  def set_resource(resource = nil)
    return super unless nested_under_study_result?

    resource ||= parent_study_result.public_send(resource_name.pluralize).find(params[:id])
    instance_variable_set("@#{resource_name}", resource)
  end

  def authorize_study_result_request
    authorize! AUTHORIZED_ACTIONS.fetch(action_name), authorization_subject
  end

  def authorization_subject
    return parent_study_result if nested_under_study_result?
    return StudyResult::StudyResult if action_name == 'index'
    return resource_class.new(resource_params) if action_name == 'create'

    get_resource
  end

  # The link a child controller must verify against the authorized study
  # result, e.g. %i[experiments experiment_id] for a stage. Controllers whose
  # child is linked directly to the study result return nil.
  def child_parent_link
    nil
  end

  def verify_child_parent
    return if child_parent_link.blank?

    association, foreign_key = child_parent_link
    parent_id = resource_params[foreign_key]
    return if parent_id.blank?
    return if parent_study_result.public_send(association).where(id: parent_id).exists?

    head :forbidden
  end
end
