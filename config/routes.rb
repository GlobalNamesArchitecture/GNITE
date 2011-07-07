Gnite::Application.routes.draw do
  match 'sign_out', :to => 'sessions#destroy', :as => :sign_out
  match 'sign_in',  :to => 'sessions#new',     :as => :sign_in
  match 'sign_up',  :to => 'users#new',        :as => :sign_up
  match "/master_trees/:id/publish" => "master_trees#publish"
  match "/master_trees/:id/undo" => "master_trees#undo"
  match "/master_trees/:id/redo" => "master_trees#redo"
  match "/tree_searches/:tree_id/:name_string" => "tree_searches#show"
  match "/push_messages" => "push_messages#update"
  match "/merge_trees/:id/populate" => "merge_trees#populate"

  resource :session, :only => [:new, :create, :destroy], :controller => "sessions"

  resources :users, :controller => 'users', :only => [:new, :create, :edit, :update] do
    resource :confirmation, :controller => 'confirmations', :only => [:new, :create]
  end

  resources :gnaclr_imports, :only => [:create]
  
  resource :gnaclr_searches, :only => [:show]

  namespace :your do
    resource :password, :only => [:edit, :update]
  end

  resources :master_trees, :only => [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :nodes,                  :only => [:index, :show, :create, :update, :destroy]
    resources :bookmarks,              :only => [:index, :create, :update, :destroy]
    resources :edits, :controller => 'master_tree_logs', :only => [:index]
    resources :flat_list_imports,      :only => [:new]
    resources :gnaclr_classifications, :only => [:index, :show]
    resources :imports,                :only => [:new]
    resource  :tree_expand,            :only => [:show]
    resources :merge_events,           :only => [:index, :create, :show, :update] { post :do, :on => :member}
  end

  resources :reference_trees, :only => [:create, :show] do
    resources :nodes,          :only => [:index, :show]
    resources :bookmarks,      :only => [:index, :create, :update, :destroy]
    resource  :tree_expand,    :only => [:show]
  end

  resources :deleted_trees, :only => [:show] do
    resources :nodes,        :only => [:index, :show]
    resource  :tree_expand,  :only => [:show]
  end
  
  resources :merge_trees, :only => [:show] do
    resources :nodes,        :only => [:index, :show]
    resource  :tree_expand,  :only => [:show]
  end
  
  root :to => "homes#show"
end
