Gnite::Application.routes.draw do
  match 'sign_out', :to => 'sessions#destroy', :as => :sign_out
  match 'sign_in',  :to => 'sessions#new',     :as => :sign_in
  match 'sign_up',  :to => 'users#new',        :as => :sign_up
  match "/master_trees/:id/publish" => "master_trees#publish"

  resource :session, :only => [:new, :create, :destroy], :controller => "sessions"

  resources :users, :controller => 'users', :only => [:new, :create, :edit, :update] do
    resource :confirmation, :controller => 'confirmations', :only => [:new, :create]
  end

  resources :gnaclr_imports, :only => [:create]

  namespace :your do
    resource :password, :only => [:edit, :update]
  end

  resources :master_trees, :only => [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :nodes, :only => [:index, :show, :create, :update, :destroy]
    resources :flat_list_imports,      :only => [:new]
    resources :gnaclr_classifications, :only => [:index, :show]
    resources :imports,                :only => [:new]
    resource :tree_expand,           :only => [:show]
  end

  resources :reference_trees, :only => [:create, :show] do
    resources :nodes,         :only => [:index, :show]
    resource :tree_expand,    :only => [:show]
  end

  resources :deleted_tree, :only => [:show] do
    resources :nodes,         :only => [:index, :show]
    resource :tree_expand,  :only => [:show]
  end

  resource :tree_search, :only => [:show]
  
  resource :gnaclr_search, :only => [:show]

  root :to => "homes#show"
end
