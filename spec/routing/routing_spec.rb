require 'spec_helper'

describe "sign_up, sign_in, sign_out" do
  it "route /users/sign_up to users/sign_up#new" do
    { get: "/users/sign_up" }.should route_to(
      controller: 'users/registrations',
      action: 'new'
    )
  end
  it "route /users/sign_in to users/sessions#new" do
    { get: "/users/sign_in" }.should route_to(
      controller: 'users/sessions',
      action: 'new'
    )
  end
  it "route /users/sign_out to users/sessions#destroy" do
    { delete: "/users/sign_out" }.should route_to(
      controller: 'users/sessions',
      action: 'destroy'
    )
  end
end

describe "routing to master_trees" do
  it "routes /master_trees to master_trees#index" do
    { get: "/master_trees" }.should route_to(
      controller: "master_trees",
      action: "index"
    )
  end
  it "routes /master_trees/new to master_trees#new" do
    { get: "master_trees/new" }.should route_to(
      controller: "master_trees",
      action: "new"
    )
  end
  it "routes /master_trees to master_trees#create" do
    { post: "/master_trees" }.should route_to(
      controller: "master_trees",
      action: "create"
    )
  end
  it "routes /master_trees/abc to master_trees#show" do
    { get: "/master_trees/abc" }.should route_to(
      controller: "master_trees",
      action: "show",
      id: "abc"
    )
  end
  it "routes /master_trees/abc/edit to master_trees#edit" do
    { get: "/master_trees/abc/edit" }.should route_to(
      controller: "master_trees",
      action: "edit",
      id: "abc"
    )
  end
    it "routes /master_trees/abc to master_trees#update" do
    { put: "/master_trees/abc" }.should route_to(
      controller: "master_trees",
      action: "update",
      id: "abc"
    )
  end
end

describe "routing to reference_trees" do
  it "routes /reference_trees to reference_trees#create" do
    {  post: "/reference_trees" }.should route_to(
       controller: "reference_trees",
       action: "create"
    )
  end
  it "routes /reference_trees/abc to reference_trees#show" do
    { get: "/reference_trees/abc" }.should route_to(
      controller: "reference_trees",
      action: "show",
      id: "abc"
    )
  end
end

describe "routing to deleted_trees" do
  it "routes /deleted_trees/:id to deleted_trees#show" do
    {  get: "/deleted_trees/12" }.should route_to(
       controller: "deleted_trees",
       action: "show",
       id: "12"
    )
  end
end

describe "routing to master tree edits" do
  it "routes /master_trees/:master_tree_id/edits to master_tree_logs#index" do
    { get: "/master_trees/123/edits" }.should route_to(
      controller: "master_tree_logs",
      action: "index",
      master_tree_id: "123"
    )
  end
end

describe "routing to nodes" do
  it "routes /master_trees/:master_tree_id/nodes to nodes#index" do
    { get: "/master_trees/123/nodes" }.should route_to(
      controller: "nodes",
      action: "index",
      master_tree_id: "123"
    )
  end
  it "routes /master_trees/:master_tree_id/nodes.json to nodes#index" do
    { get: "/master_trees/123/nodes.json" }.should route_to(
      controller: "nodes",
      action: "index",
      master_tree_id: "123",
      format: "json"
    )
  end
  it "routes POST /master_trees/:master_tree_id/nodes.json to nodes#create" do
    { post: "/master_trees/123/nodes.json" }.should route_to(
      controller: "nodes",
      action: "create",
      master_tree_id: "123",
      format: "json"
    )
  end
  it "routes PUT /master_trees/:master_tree_id/nodes/:id.json to nodes#update" do
    { put: "/master_trees/123/nodes/abc.json" }.should route_to(
      controller: "nodes",
      action: "update",
      master_tree_id: "123",
      id: "abc",
      format: "json"
    )
  end
  it "routes DELETE /master_trees/:master_tree_id/nodes/:id.json to nodes#delete" do
    { delete: "/master_trees/123/nodes/abc.json" }.should route_to(
      controller: "nodes",
      action: "destroy",
      master_tree_id: "123",
      id: "abc",
      format: "json"
    )
  end

  it "routes /reference_trees/:reference_tree_id/nodes to nodes#index" do
    { get: "/reference_trees/123/nodes" }.should route_to(
      controller: "nodes",
      action: "index",
      reference_tree_id: "123"
    )
  end
  it "routes /reference_trees/:reference_tree_id/nodes.json to nodes#index" do
    { get: "/reference_trees/123/nodes.json" }.should route_to(
      controller: "nodes",
      action: "index",
      reference_tree_id: "123",
      format: "json"
    )
  end

  it "routes /deleted_trees/:deleted_tree_id/nodes to nodes#index" do
    { get: "/deleted_trees/123/nodes" }.should route_to(
      controller: "nodes",
      action: "index",
      deleted_tree_id: "123"
    )
  end
  it "routes /deleted_trees/:deleted_tree_id/nodes.json to nodes#index" do
    { get: "/deleted_trees/123/nodes.json" }.should route_to(
      controller: "nodes",
      action: "index",
      deleted_tree_id: "123",
      format: "json"
    )
  end

  it "routes /merge_trees/:merge_tree_id/nodes to nodes#index" do
    { get: "/merge_trees/123/nodes" }.should route_to(
      controller: "nodes",
      action: "index",
      merge_tree_id: "123"
    )
  end
  it "routes /merge_trees/:merge_tree_id/nodes.json to nodes#index" do
    { get: "/merge_trees/123/nodes.json" }.should route_to(
      controller: "nodes",
      action: "index",
      merge_tree_id: "123",
      format: "json"
    )
  end

end

describe "routing to node metadata" do
  it "routes /master_trees/:master_tree_id/nodes/:id to nodes#show" do
    { get: "/master_trees/123/nodes/12" }.should route_to(
      controller: "nodes",
      action: "show",
      master_tree_id: "123",
      id: "12"
    )
  end
  it "routes /reference_trees/:reference_tree_id/nodes/:id to nodes#show" do
    { get: "/reference_trees/123/nodes/12" }.should route_to(
      controller: "nodes",
      action: "show",
      reference_tree_id: "123",
      id: "12"
    )
  end
  it "routes /merge_trees/:merge_tree_id/nodes/:id to nodes#show" do
    { get: "/merge_trees/123/nodes/12" }.should route_to(
      controller: "nodes",
      action: "show",
      merge_tree_id: "123",
      id: "12"
    )
  end
end

describe "routing to merge events" do
  
  it "routes /master_trees/:master_tree_id/merge_events to merge_events#index" do
    { get: "/master_trees/123/merge_events" }.should route_to(
      controller: "merge_events",
      action: "index",
      master_tree_id: "123"
    )
  end
  
  it "routes /master_trees/:master_tree_id/merge_events to merge_events#create" do
    { post: "/master_trees/123/merge_events" }.should route_to(
      controller: "merge_events",
      action: "create",
      master_tree_id: "123"
    )
  end

  it "routes /master_trees/:master_tree_id/merge_events/:id to merge_events#show" do
    { get: "/master_trees/123/merge_events/12" }.should route_to(
      controller: "merge_events",
      action: "show",
      master_tree_id: "123",
      id: "12"
    )
  end

  it "routes /master_trees/:master_tree_id/merge_events/:id to merge_events#show" do
    { get: "/master_trees/123/merge_events/12" }.should route_to(
      controller: "merge_events",
      action: "show",
      master_tree_id: "123",
      id: "12"
    )
  end

  it "routes /master_trees/:master_tree_id/merge_events/:id to merge_events#update" do
    { put: "/master_trees/123/merge_events/12" }.should route_to(
      controller: "merge_events",
      action: "update",
      master_tree_id: "123",
      id: "12"
    )
  end

end

describe "imports" do
  it "routes /master_trees/:master_tree_id/imports/new to imports#new" do
    { get: "/master_trees/123/imports/new" }.should route_to(
      controller: 'imports',
      action: 'new',
      master_tree_id: "123"
    )
  end
end

describe "GNACLR import" do
  it "routes /master_trees/:master_tree_id/gnaclr_classifications to gnaclr_classifications#index" do
    { get: "/master_trees/123/gnaclr_classifications" }.should route_to(
      controller: 'gnaclr_classifications',
      action: 'index',
      master_tree_id: '123'
    )
  end

  it "routes /master_trees/:master_tree_id/gnaclr_classifications/:id to gnaclr_classifications#show" do
    { get: "/master_trees/123/gnaclr_classifications/my-uuid-here" }.should route_to(
      controller: 'gnaclr_classifications',
      action: 'show',
      id: 'my-uuid-here',
      master_tree_id: '123'
    )
  end
end

describe "Flat list import" do
  it "routes /master_trees/:master_tree_id/flat_list_imports/new to flat_list_imports#new" do
    { get: "/master_trees/123/flat_list_imports/new" }.should route_to(
      controller: 'flat_list_imports',
      action: 'new',
      master_tree_id: '123'
    )
  end
end

describe "routing to bookmarks" do
  it "routes /master_trees/:master_tree_id/bookmarks to bookmarks#index" do
    { get: "/master_trees/123/bookmarks" }.should route_to(
      controller: "bookmarks",
      action: "index",
      master_tree_id: "123"
    )
  end
  it "routes POST /master_trees/:master_tree_id/bookmarks to bookmarks#create" do
    { post: "/master_trees/123/bookmarks" }.should route_to(
      controller: "bookmarks",
      action: "create",
      master_tree_id: "123"
    )
  end
  it "routes DELETE /master_trees/:master_tree_id/bookmarks/:id to bookmarks#delete" do
    { delete: "/master_trees/123/bookmarks/45" }.should route_to(
      controller: "bookmarks",
      action: "destroy",
      master_tree_id: "123",
      id: "45"
    )
  end
  it "routes /reference_trees/:reference_tree_id/bookmarks to bookmarks#index" do
    { get: "/reference_trees/123/bookmarks" }.should route_to(
      controller: "bookmarks",
      action: "index",
      reference_tree_id: "123"
    )
  end
  it "routes POST /reference_trees/:reference_tree_id/bookmarks to bookmarks#create" do
    { post: "/reference_trees/123/bookmarks" }.should route_to(
      controller: "bookmarks",
      action: "create",
      reference_tree_id: "123"
    )
  end
  it "routes DELETE /reference_trees/:reference_tree_id/bookmarks/:id to bookmarks#delete" do
    { delete: "/reference_trees/123/bookmarks/45" }.should route_to(
      controller: "bookmarks",
      action: "destroy",
      reference_tree_id: "123",
      id: "45"
    )
  end
end

describe "search in trees" do
  it "routes GET /tree_searches/:tree_id/:name_string tree_searches#get" do
    { get: "/tree_searches/123/gnite" }.should route_to(
      controller: "tree_searches",
      action: "show",
      tree_id: "123",
      name_string: "gnite"
    )
  end
end

describe "languges list" do
  it "routes GET /languages to languages#show" do
    { get: "/languages" }.should route_to(
      controller: "languages",
      action: "show"
    )
  end
end

describe "vocabularies list" do
  it "routes GET /vocabularies/:id to vocabularies#show" do
    { get: "/vocabularies/ranks" }.should route_to(
      controller: "controlled_vocabularies",
      action: "show",
      id: "ranks"
    )
  end
end

describe "routing to admin" do
  it "routes GET /admin#show" do
    { get: "/admin" }.should route_to(
      controller: "admin/menu",
      action: "show"
    )
  end
  it "routes GET /admin/users#get" do
    { get: "/admin/users" }.should route_to(
      controller: "admin/users",
      action: "index"
    )
  end
  it "routes GET /admin/users#post" do
    { post: "/admin/users" }.should route_to(
      controller: "admin/users",
      action: "create"
    )
  end
  it "routes GET /admin/users/new#get" do
    { get: "/admin/users/new" }.should route_to(
      controller: "admin/users",
      action: "new"
    )
  end
  it "routes GET /admin/users/:id#show" do
    { get: "/admin/users/99" }.should route_to(
      controller: "admin/users",
      action: "show",
      id: "99"
    )
  end
  it "routes PUT /admin/users/:id#put" do
    { put: "/admin/users/99" }.should route_to(
      controller: "admin/users",
      action: "update",
      id: "99"
    )
  end
end
