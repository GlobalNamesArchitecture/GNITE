Gnite::Application.routes.draw do |map|
  match 'sign_out' => 'sessions#destroy', :as => :sign_out
  match 'sign_in'  => 'sessions#new',     :as => :sign_in
  match 'sign_up'  => 'users#new',        :as => :sign_up

  resource :session, :only => [:new, :create, :destroy], :controller => "sessions"

  resources :users, :controller => 'users', :only => [:new, :create, :edit, :update] do
    resource :confirmation, :controller => 'confirmations', :only => [:new, :create]
  end

  resources :gnaclr_imports, :only => [:create]

  namespace :your do
    resource :password, :only => [:edit, :update]
  end

  resources :master_trees, :only => [:index, :new, :create, :show, :edit, :update] do
    resources :nodes, :only => [:index, :create, :update, :destroy] do
      resource :clone, :only => [:create]
    end
    resources :flat_list_imports,      :only => [:new]
    resources :gnaclr_classifications, :only => [:index, :show]
    resources :imports,                :only => [:new]
  end

  resources :reference_trees, :only => [:create, :show] do
    resources :nodes,         :only => [:index]
  end

  root :to => "homes#show"
end
