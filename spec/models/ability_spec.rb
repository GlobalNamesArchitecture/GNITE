require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  before(:each) do
    @user  = Factory(:user)
    @user2 = Factory(:user)
    @master_editor = Factory(:user)
    @master_editor.roles = [Factory(:role, :name => "master_editor")]
    @master_editor.save!
    @admin = Factory(:user)
    @admin.roles = [Factory(:role, :name => "admin")]
    @admin.save!
  end

  describe 'guest user' do
    before(:each) do
      @guest = nil
      @ability = Ability.new(@guest)
    end

    it "should_not list other users" do
      @ability.should_not be_able_to(:index, User)
    end

    it "should_not show other user" do
      @ability.should_not be_able_to(:show, @user)
    end

    it "should_not create other user" do
      @ability.should_not be_able_to(:create, User)
    end

    it "should_not edit other user" do
      @ability.should_not be_able_to(:edit, @user)
    end
    
    it "should_not update other user" do
      @ability.should_not be_able_to(:update, @user)
    end

    it "should_not destroy other user" do
      @ability.should_not be_able_to(:destroy, @user)
    end
    
    it "should_not show admin menu" do
      @ability.should_not be_able_to(:show, Menu)
    end
    
    it "should_not list master trees" do
      master_tree = Factory(:master_tree, :user_id => @user.id)
      @ability.should_not be_able_to(:index, master_tree)
    end

    it "should_not edit others' master trees metadata" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:edit, master_tree)
    end
    
    it "should_not update others' master trees metadata" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:update, master_tree)
    end
    
    it "should_not publish others' master trees" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:publish, master_tree)
    end
    
    it "should_not destroy others' master trees" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:destroy, master_tree)
    end
    
  end
  
  describe 'authenticated user' do
    before(:each) do
      @ability = Ability.new(@user)
    end

    it "should_not list other users" do
      @ability.should_not be_able_to(:index, User)
    end

    it "should_not show other user" do
      @ability.should_not be_able_to(:show, @user2)
    end

    it "should_not create other user" do
      @ability.should_not be_able_to(:create, User)
    end

    it "should_not edit other user" do
      @ability.should_not be_able_to(:edit, @user2)
    end
    
    it "should_not update other user" do
      @ability.should_not be_able_to(:update, @user2)
    end

    it "should_not destroy other user" do
      @ability.should_not be_able_to(:destroy, @user2)
    end
    
    it "should_not show admin menu" do
      @ability.should_not be_able_to(:show, Menu)
    end
    
    it "should create a master tree" do
      @ability.should be_able_to(:new, MasterTree)
    end
    
    it "should_not list others' master trees" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:index, master_tree)
    end
    
    it "should_not show others' master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:show, master_tree)
    end

    it "should_not undo action in others' master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:undo, master_tree)
    end

    it "should_not redo action in others' master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:redo, master_tree)
    end
    
    it "should_not edit others' master tree metadata" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:edit, master_tree)
    end
    
    it "should_not update others' master tree metadata" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:update, master_tree)
    end
    
    it "should_not publish others' master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:publish, master_tree)
    end

    it "should_not edit others' master tree metadata even with access to edit node" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      @ability.should_not be_able_to(:edit, master_tree)
    end
    
    it "should_not update others' master tree metadata even with access to edit node" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      @ability.should_not be_able_to(:update, master_tree)
    end
    
    it "should_not publish others' master tree even with access to edit node" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      @ability.should_not be_able_to(:publish, master_tree)
    end
    
    it "should_not destroy others' master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      @ability.should_not be_able_to(:destroy, master_tree)
    end
    
    it "should_not update node in inaccessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      node = Factory(:node, :tree => master_tree)
      @ability.should_not be_able_to(:update, node)
    end
    
    it "should_not update synonym for node in inaccessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      node = Factory(:node, :tree => master_tree)
      synonym = Factory(:synonym, :node => node)
      @ability.should_not be_able_to(:update, synonym)
    end

    it "should_not destroy synonym for node in inaccessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      node = Factory(:node, :tree => master_tree)
      synonym = Factory(:synonym, :node => node)
      @ability.should_not be_able_to(:destroy, synonym)
    end

    it "should_not update vernacular for node in inaccessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      node = Factory(:node, :tree => master_tree)
      vernacular_name = Factory(:vernacular_name, :node => node)
      @ability.should_not be_able_to(:update, vernacular_name)
    end

    it "should_not destroy vernacular for node in inaccessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      node = Factory(:node, :tree => master_tree)
      vernacular_name = Factory(:vernacular_name, :node => node)
      @ability.should_not be_able_to(:destroy, vernacular_name)
    end

    it "should undo action in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      @ability.should be_able_to(:undo, master_tree)
    end

    it "should redo action in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      @ability.should be_able_to(:redo, master_tree)
    end

    it "should update node in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      node = Factory(:node, :tree => master_tree)
      @ability.should be_able_to(:update, node)
    end
    
    it "should update synonym for node in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      node = Factory(:node, :tree => master_tree)
      synonym = Factory(:synonym, :node => node)
      @ability.should be_able_to(:update, synonym)
    end

    it "should destroy synonym for node in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      node = Factory(:node, :tree => master_tree)
      synonym = Factory(:synonym, :node => node)
      @ability.should be_able_to(:destroy, synonym)
    end

    it "should update vernacular for node in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      node = Factory(:node, :tree => master_tree)
      vernacular_name = Factory(:vernacular_name, :node => node)
      @ability.should be_able_to(:update, vernacular_name)
    end

    it "should destroy vernacular for node in accessible master tree" do
      master_tree = Factory(:master_tree, :user_id => @user2.id)
      Factory(:master_tree_contributor, :user => @user, :master_tree => master_tree)
      node = Factory(:node, :tree => master_tree)
      vernacular_name = Factory(:vernacular_name, :node => node)
      @ability.should be_able_to(:destroy, vernacular_name)
    end
    
  end
  
  describe 'master editor' do
    before(:each) do
      @ability = Ability.new(@master_editor)
    end
    
    it "should show admin menu" do
      @ability.should be_able_to(:show, Menu)
    end
    
    it "should list other users" do
      @ability.should be_able_to(:index, User)
    end

    it "should_not show other user" do
      @ability.should_not be_able_to(:show, @user)
    end

    it "should_not create other user" do
      @ability.should_not be_able_to(:create, User)
    end

    it "should_not edit other user" do
      @ability.should_not be_able_to(:edit, @user)
    end
    
    it "should_not update other user" do
      @ability.should_not be_able_to(:update, @user)
    end

    it "should_not destroy other user" do
      @ability.should_not be_able_to(:destroy, @user)
    end
    
  end
  
  describe 'admin user' do
    before(:each) do
      @ability = Ability.new(@admin)
    end

    it "should show admin menu" do
      @ability.should be_able_to(:show, Menu)
    end
    
    it "should list other users" do
      @ability.should be_able_to(:index, User)
    end
    
    it "should show other user" do
      @ability.should be_able_to(:show, @user)
    end
    
    it "should create other user" do
      @ability.should be_able_to(:create, User)
    end

    it "should update other user" do
      @ability.should be_able_to(:update, @user)
    end

    it "should destroy other user" do
      @ability.should be_able_to(:destroy, @user)
    end
    
  end

end
