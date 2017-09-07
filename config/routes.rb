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

  scope :api do   
    scope :v1 do
      devise_for :users

      use_doorkeeper do
        #skip_controllers :authorizations, :applications, :authorized_applications
      end

      resources :study_protocols
      resources :protocol_definitions
      resources :study_definitions do
        resources :protocols, :controller => "study_protocols"
      end
    end
  end

  get '/admin'  => 'admin#index'
  get '/admin/users'  => 'admin#index'
  get '/admin/studies'  => 'admin#index'
  match '/admin/*remainder' => 'admin#index', via: :all
end
