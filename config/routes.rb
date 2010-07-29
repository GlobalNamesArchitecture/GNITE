Gnite::Application.routes.draw do |map|
  resource :session, :only => [:new, :create, :destroy], :controller => "sessions"

  match 'sign_out' => 'sessions#destroy', :as => :sign_out
  match 'sign_in' => 'sessions#new', :as => :sign_in

  resources :users, :controller => 'users', :only => [:new, :create, :edit, :update] do
    resource :confirmation, :controller => 'confirmations', :only => [:new, :create]
  end

  namespace :your do
    resource :password, :only => [:edit, :update]
  end

  resources :trees, :only => [:index, :new, :create, :show]
  root :to => "homes#show"
end
