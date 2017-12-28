module Api::V1
  class UsersController < Devise::RegistrationsController

    include ElicitErrors

    #include StudyCreation

    before_action -> { doorkeeper_authorize! :public }, only: [:update, :index]
    before_action only: [:new, :create] do |controller| # access to register api requires authenticated client token
#      doorkeeper_authorize! :public unless controller.request.format.html?
    end
    before_action :authenticate_scope!, only: [:edit, :destroy]
    before_action only: [:update] do |controller|
      autenticate_user! unless controller.request.format.json?
    end

    respond_to :json

    rescue_from ElicitError, :with => :render_elicit_error

    def create
      build_resource(sign_up_params)
      resource.save
      yield resource if block_given?
      if ! resource.persisted?
        clean_up_passwords resource
        set_minimum_password_length
        e = ElicitError.new("Cannot create user", :unprocessable_entity, details: resource.errors)
        render_elicit_error e
      else
        render json: resource, status: :created
      end
    end

    def update
      @user = current_resource_owner
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unauthorized
      end
    end

    def index
      if !params.has_key?(:query) or params[:query].length < 3
        @users = User.all()
      else
        username_query = { username: /#{params[:query]}/i }
        email_query = {email: params[:query]}
        @users = User.or(username_query, email_query).all()
      end
      render json: @users
    end

    def show
      logger.warn "SHOW #{params[:id]}"
      @user = User.find_by(id: params[:id]) || User.find_by(username: params[:id]) || User.find_by(email: params[:id]) || not_found

      if @user
        render json: @user, status: :ok
      else
        not_found
      end
    end

    def show_current_user
      @user = current_resource_owner or permission_denied
      render json: @user
    end

    private

    def resource_name
      :user
    end

    def user_params
      params.permit!
      ap params
      params.require(:user).permit(:email, :username, :password, :password_confirmation)
    end

    def sign_up_params
      user_params
    end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token && doorkeeper_token.resource_owner_id
    end
  end
end
