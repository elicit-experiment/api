# frozen_string_literal: true

module Api
  module V1
    class UsersController < Devise::RegistrationsController
      include ElicitErrors

      include PaginationHeaderLinks

      before_action -> { doorkeeper_authorize! :public }, only: %i[update index]
      before_action only: %i[new create] do |controller| # access to register api requires authenticated client token
        #      doorkeeper_authorize! :public unless controller.request.format.html?
      end
      before_action :authenticate_scope!, only: %i[edit destroy]
      before_action only: [:update] do |controller|
        authenticate_user! unless controller.request.format.json?
      end

      rescue_from CanCan::AccessDenied do |_exception|
        head :forbidden
      end

      respond_to :json

      rescue_from ElicitError, with: :render_elicit_error

      def create
        if current_resource_owner
          # Create user via api...
          if sign_up_params[:role] == User::ROLES[:admin]
            authorize! :create_admin, User
          elsif sign_up_params[:role] == User::ROLES[:investigator]
            authorize! :create_investigator, User
          else
            authorize! :create_standard, User
          end
        else
          # Create user via sign up
          sign_up_params[:role] = User::ROLES[:registered]
        end

        build_resource(sign_up_params)
        resource.save
        yield resource if block_given?
        if !resource.persisted?
          clean_up_passwords resource
          set_minimum_password_length
          e = ElicitError.new('Cannot create user', :unprocessable_entity, details: resource.errors)
          Rails.logger.info message: 'user error', errors: resource.errors
          render_elicit_error e
        else
          render json: resource, status: :created
        end
      end

      def update
        @user = User.find(params[:id])
        logger.info @user.role
        logger.info [User::ROLES[:admin]].include?(@user.role)
        authorize! :upgrade, @user if user_params.key? :role
        if @user.update!(user_params.merge({ updated_at: Time.now }))
          render json: @user
        else
          render json: @user.errors, status: :unauthorized
        end
      end

      def index
        if !params.key?(:query) || (params[:query].length < 3)
          if params.key?(:q)
            username_query = { username: /#{params[:q]}/i }
            email_query = { email: params[:q] }
            @all_users = User.or(username_query, email_query).all
          else
            @all_users = User.all
          end
        else
          @all_users = User.where(email: params[:query]).or(User.where(username: params[:query]))
        end

        authorize! :read, User

        @all_users = @all_users.where.not(role: User::ROLES[:admin]).where.not(role: User::ROLES[:investigator]) unless current_user.is_admin?

        unless page_params.nil?
          @users = @all_users.page(page_params[:page])
                             .per(page_params[:page_size])
        end

        # render json: { page: page_params[:page], total_items: @all_users.size }
        set_pagination_headers @users, @all_users, page_params

        render json: @users
      end

      def show
        @user = User.find_by(id: params[:id]) || User.find_by(username: params[:id]) || User.find_by(email: params[:id]) || not_found

        if @user
          render json: @user, status: :ok
        else
          not_found
        end
      end

      def show_current_user
        (@user = current_resource_owner) || permission_denied
        render json: @user
      end

      def edit; super; end

      def destroy; super; end

      private

      def resource_name
        :user
      end

      def user_params
        @user_params ||= params.require(:user).permit(:email, :username, :password, :password_confirmation, :role, :auto_created)
        @user_params
      end

      def sign_up_params
        @sign_up_params ||= user_params
        @sign_up_params
      end

      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token&.resource_owner_id
      end
    end
  end
end
