# frozen_string_literal: true

Rails.application.routes.draw do
  # root of site
  root 'client_app#index', as: :client_app

  #match '*unmatched_route' => 'application#not_found'

  mount SwaggerUiEngine::Engine, at: '/api-docs'

  get '/apidocs/v1/swagger.json' => 'apidocs#index', :defaults => { format: 'json' }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # routes to enable the CHAOS protocol used by the clients
  scope :v6 do
    get 'Session/Create' => 'chaos_api/v6/sessions#create', :defaults => { format: 'json' }
    get 'Experiment/Get' => 'chaos_api/v6/experiments#show', :defaults => { format: 'json' }
    get 'Question/Get' => 'chaos_api/v6/question#show', :defaults => { format: 'json' }
    post 'Answer/Set' => 'chaos_api/v6/answer#create', :defaults => { format: 'json' }, as: :chaos_api_v6_answer_create
    get 'Answer/Set' => 'chaos_api/v6/answer#create', :defaults => { format: 'json' }, as: :chaos_api_v6_answer_get
    post 'Slide/DataPoint' => 'chaos_api/v6/time_series#data_point', :defaults => { format: 'json' }, as: :chaos_api_v6_slide_datapoint
    get 'Slide/Completed' => 'chaos_api/v6/slide#get', :defaults => { format: 'json' }
    match 'Answer/Set', to: 'chaos_api/v6/answer#cors_set_access_control_headers', via: :options
    post 'time_series/:series_type' => 'chaos_api/v6/time_series#create', :defaults => { format: 'json' }
    post 'time_series/:series_type/file' => 'chaos_api/v6/time_series#append', as: :chaos_api_v6_time_series_file
    post 'time_series/:series_type/file_raw' => 'chaos_api/v6/time_series_raw#append', as: :chaos_api_v6_time_series_raw

    get '/*' => redirect('/')
  end

  scope :chaos do
    get 'endexperiment' => 'chaos#endexperiment', as: :chaos_endexperiment

    # scope '/(:session_guid)/v6' do
    #   get 'Session/Create' => 'chaos_api/v6/sessions#create', :defaults => { format: 'json' }
    #   get 'Experiment/Get' => 'chaos_api/v6/experiments#show', :defaults => { format: 'json' }
    #   get 'Question/Get' => 'chaos_api/v6/question#show', :defaults => { format: 'json' }
    #   post 'Answer/Set' => 'chaos_api/v6/answer#create', :defaults => { format: 'json' }
    #   get 'Answer/Set' => 'chaos_api/v6/answer#create', :defaults => { format: 'json' }
    #   post 'Slide/DataPoint' => 'chaos_api/v6/time_series#summary', :defaults => { format: 'json' }
    #   get 'Slide/Completed' => 'chaos_api/v6/slide#get', :defaults => { format: 'json' }
    #   match 'Answer/Set', to: 'chaos_api/v6/answer#cors_set_access_control_headers', via: :options
    #   post 'time_series/:series_type' => 'chaos_api/v6/time_series#create', :defaults => { format: 'json' }
    #   post 'time_series/:series_type/file' => 'chaos_api/v6/time_series#append'
    # end
  end

  # API
  namespace :api do
    namespace :v1 do
      get 'participant/eligeable_protocols' => 'participant#eligeable_protocols'
      get 'participant/anonymous_protocols' => 'participant#anonymous_protocols'
      get 'participant/anonymous_protocols/:id' => 'participant#anonymous_protocol'
      resources :study_results, controller: 'study_results', defaults: { format: 'json' }, only: %i[show destroy create index] do
        resources :experiments, controller: 'experiments', defaults: { format: 'json' }, only: %i[show destroy create index]
        resources :stages, controller: 'stages', defaults: { format: 'json' }, only: %i[show destroy create index]
        resources :trial_results, controller: 'trial_results', defaults: { format: 'json' }, only: %i[show destroy create index]
        resources :data_points, controller: 'data_points', defaults: { format: 'json' }, only: [:index]
        resources :time_series, controller: 'time_series', only: %i[destroy show update create index] do
          get 'content' => 'time_series/content#show', as: :content
        end
      end
      resources :media_files, defaults: { format: 'json' }, only: %i[destroy show update create index]
      resources :study_definitions, defaults: { format: 'json' }, only: %i[destroy show update create index] do
        resources :protocol_definitions, controller: 'protocol_definitions', defaults: { format: 'json' }, only: %i[destroy show update create index] do
          get 'take' => 'protocol_definitions#take'
          resources :users, controller: 'protocol_users', defaults: { format: 'json' }, only: %i[show destroy create index]
          resources :phase_order, controller: 'phase_order', defaults: { format: 'json' }, only: %i[show update create]
          resources :phase_definitions, controller: 'phase_definitions', defaults: { format: 'json' }, only: %i[destroy show update create index] do
            resources :trial_order, controller: 'trial_order', defaults: { format: 'json' }, only: %i[show update create]
            resources :trial_definitions, controller: 'trial_definitions', defaults: { format: 'json' }, only: %i[destroy show update create index] do
              resources :data_points, controller: 'data_points', defaults: { format: 'json' }, only: %i[index show update create]
              resources :components, controller: 'components', defaults: { format: 'json' }, only: %i[destroy show update create index]
              resources :stimuli, controller: 'stimuli', defaults: { format: 'json' }, only: %i[destroy show update create index]
            end
          end
        end
      end
    end
  end

  scope :api do
    scope :v1 do
      get 'study_definitions/:study_definition_id/protocol_definitions/:protocol_definition_id/preview' => 'protocol_preview#take'
      get 'study_results/time_series/:id/content' => 'api/v1/time_series/content#show'
      get 'study_definitions/components/:id' => 'api/v1/components#show', defaults: { format: 'json' }, only: [:show]
      scope :study_definitions do
        scope :protocol_definitions do
          get 'preview' => 'protocol_preview#take'
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
        get 'users/current' => 'api/v1/users#show_current_user'
        resources :users, only: %i[show index update delete], controller: 'api/v1/users', defaults: { format: 'json' }, constraints: { id: %r{[0-9]+} } do
        end
      end
      use_doorkeeper
    end
  end

  # Contact form submission endpoint
  post '/contact' => 'client_app#contact', defaults: { format: 'json' }

  ## Client app pages -- just load the client app
  get '/admin' => 'client_app#index', as: :client_app_admin, constraints: { format: 'html' }
  get '/admin/:tab' => 'client_app#index', constraints: { format: 'html' }
  get '/participant' => 'client_app#index', as: :client_app_participant, constraints: { format: 'html' }
  get '/login' => 'client_app#index', as: :client_app_login, constraints: { format: 'html' }
  get '/contact' => 'client_app#index', as: :client_app_contact, constraints: { format: 'html' }
  match '/client_app/*remainder' => 'client_app#index', via: :all, constraints: { format: 'html' }
  match '/participant/*remainder' => 'client_app#index', via: :all, constraints: { format: 'html' }
  match '/login/*remainder' => 'client_app#index', via: :all, constraints: { format: 'html' }

  # catch all routes must allow the active storage (/rails) routes
  match '/*path' => 'client_app#index', via: :all, constraints: lambda { |request| request.format == 'html' && !request.path.start_with?('/rails') }

  # catchall, not found
  match '*path', to: 'application#not_found', via: :all, constraints: lambda { |request| !request.path.start_with?('/rails') }
end
