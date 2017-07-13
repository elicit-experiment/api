Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #root of site
  root 'experiments#index'

  #regular route, GET request for /about also routes to pages/about
  get 'about' => 'pages#about'

  #set all the CRUD methods (maps HTTP verbs to controller actions)
  resources :experiments do
    resources :trials
  end

  get '/v6/Session/Create' => 'sessions#create' , :defaults => { :format => 'json' }
  get '/v6/Experiment/Get' => 'experiments#show' , :defaults => { :format => 'json' }
  get '/v6/Question/Get' => 'question#show' , :defaults => { :format => 'json' }
  post '/v6/Answer/Set' => 'answer#create' , :defaults => { :format => 'json' }
  get '/v6/Answer/Set' => 'answer#create' , :defaults => { :format => 'json' }
  match '/v6/Answer/Set', to: 'answer#cors_set_access_control_headers', via: :options

  get "/v6/*" => redirect("/")
end
