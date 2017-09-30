Rails.application.routes.draw do

  mount SwaggerUiEngine::Engine, at: "/api-docs"

  get '/apidocs/v1/swagger.json' => 'apidocs#index', :defaults => { :format => 'json' }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #root of site
  root 'experiments#index'

  #regular route, GET request for /about also routes to pages/about
  get 'about' => 'pages#about'

  #set all the CRUD methods (maps HTTP verbs to controller actions)
  resources :experiments do
    resources :trials
  end

  # routes to enable the CHAOS protocol used by the clients
  get '/v6/Session/Create' => 'sessions#create' , :defaults => { :format => 'json' }
  get '/v6/Experiment/Get' => 'experiments#show' , :defaults => { :format => 'json' }
  get '/v6/Question/Get' => 'question#show' , :defaults => { :format => 'json' }
  post '/v6/Answer/Set' => 'answer#create' , :defaults => { :format => 'json' }
  get '/v6/Answer/Set' => 'answer#create' , :defaults => { :format => 'json' }
  get '/v6/Slide/Completed' => 'slide#get' , :defaults => { :format => 'json' }
  match '/v6/Answer/Set', to: 'answer#cors_set_access_control_headers', via: :options

  get "/v6/*" => redirect("/")

  # API
  namespace :api do
    namespace :v1 do
      resources :study_definitions, defaults: { format: 'json' }, only: [:destroy, :show, :update, :create, :index] do
        resources :protocol_definitions, :controller => "protocol_definitions", defaults: { format: 'json' }, only: [:destroy, :show, :update, :create, :index] do
          resources :phase_order, :controller => "phase_order", defaults: { format: 'json' }, only: [:show, :update, :create]
          resources :phase_definitions, :controller => "phase_definitions", defaults: { format: 'json' }, only: [:destroy, :show, :update, :create, :index] do
            resources :trial_order, :controller => "trial_order", defaults: { format: 'json' }, only: [:show, :update, :create]
            resources :trial_definitions, :controller => "trial_definitions", defaults: { format: 'json' }, only: [:destroy, :show, :update, :create, :index] do
              resources :components, :controller => "components", defaults: { format: 'json' }, only: [:destroy, :show, :update, :create, :index] do
              end
              resources :stimuli, :controller => "stimuli", defaults: { format: 'json' }, only: [:destroy, :show, :update, :create, :index] do
              end
            end
          end
        end
      end
    end
  end

  # users/auth
  scope :api do
    scope :v1 do
      devise_for :users, controllers: {
        registrations: 'api/v1/users',
        confirmations: 'api/v1/confirmations'
      }
      devise_scope :user do
        get 'users/current' => "api/v1/users#show_current_user"
        resources :users, only: [:show, :index], controller: 'api/v1/users', :defaults => { :format => 'json' }, :constraints => { :id => /[^\/]+/ } do
        end
      end
      use_doorkeeper
    end
  end

  ## Admin app pages -- just load the client app

  get '/admin'  => 'admin#index'
  get '/admin/users'  => 'admin#index'
  get '/admin/studies'  => 'admin#index'
  match '/admin/*remainder' => 'admin#index', via: :all
end
