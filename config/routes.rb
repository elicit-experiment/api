Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

#root of site
root 'experiments#index'

#regular route
get 'about' => 'pages#about'

#set all the CRUD methods (maps HTTP verbs to controller actions)
resources :experiments do
  resources :trials
end


end
