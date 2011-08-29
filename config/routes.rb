Gnite::Application.routes.draw do

  devise_for :users, :controllers => {
    :sessions => "users/sessions",
    :registrations => "users/registrations",
    :passwords => "users/passwords",
    :confirmations => "users/confirmations",
    :unlocks => "users/unlocks"
  }

  match "/master_trees/:id/publish" => "master_trees#publish"
  match "/master_trees/:id/undo" => "master_trees#undo"
  match "/master_trees/:id/redo" => "master_trees#redo"
  match "/tree_searches/:tree_id/:name_string" => "tree_searches#show"
  match "/push_messages" => "push_messages#update"
  match "/merge_trees/:id/populate" => "merge_trees#populate"

  resources :gnaclr_imports, :only => [:create]
  
  resource :gnaclr_searches, :only => [:show]

  resources :master_trees, :only => [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :nodes,                  :only => [:index, :show, :create, :update, :destroy] do
      resources :synonyms,                :only => [:create, :update, :destroy]
      resources :vernacular_names,        :only => [:create, :update, :destroy]
    end
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
  
  resource :languages, :only => [:show]
  
  resources :vocabularies, :controller => :controlled_vocabularies, :only => [:show] do
    resources :terms, :controller => :controlled_terms, :only => [:show]
  end
  
  resource :administration, :controller => "administration/menu", :only => [:show]
  
  root :to => "homes#show"
end
