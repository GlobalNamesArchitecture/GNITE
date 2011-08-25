require 'spec_helper'

describe GnaclrClassificationsController do
  context "when signed out" do
    describe "on GET to index" do
      before do
        get :index, :master_tree_id => 123
      end

      subject { controller }

      it { should redirect_to(new_user_session_url) }
      it { should set_the_flash.to(/sign in/) }
    end
  end

  context "signed in with some remote GNACLR classifications" do
    let(:user) { Factory(:user) }
    let(:master_tree)  { Factory(:master_tree, :user => user) }
    let(:master_trees) { [master_tree] }

    before do
      sign_in user
      master_trees.stubs(:find => master_tree)
    end

    describe "on GET to index" do
      let(:gnaclr_classifications) { 'fake classifications' }

      before do
        controller.stubs(:current_user => user)
        user.stubs(:master_trees => master_trees)
        GnaclrClassification.stubs(:all => gnaclr_classifications)
        get :index, :master_tree_id => master_tree.to_param
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template('index') }

      it 'should assign_to(:gnaclr_classifications).with(gnaclr_classifications)' do
        assigns(:gnaclr_classifications).should == gnaclr_classifications
      end

      it "should find all the GnaclrClassifications" do
        GnaclrClassification.should have_received(:all).with()
      end

      it 'should assign_to(:master_tree).with(master_tree)' do
        assigns(:master_tree).should == master_tree
      end

      it "should find the correct master tree" do
        user.should have_received(:master_trees).with()
        master_trees.should have_received(:find).with(master_tree.to_param)
      end
    end

    describe "on GET to show with a UUID passed as :id" do
      let(:gnaclr_classification) { 'fake classification' }

      before do
        controller.stubs(:current_user => user)
        user.stubs(:master_trees => master_trees)
        GnaclrClassification.stubs(:find_by_uuid => gnaclr_classification)
        get :show, :master_tree_id => master_tree.to_param, :id => 'the-uuid'
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template('show') }

      it 'should assign_to(:gnaclr_classification).with(gnaclr_classification)' do
        assigns(:gnaclr_classification).should == gnaclr_classification
      end

      it "should find all the GnaclrClassifications" do
        GnaclrClassification.should have_received(:find_by_uuid).with('the-uuid')
      end

      it 'should assign_to(:master_tree).with(master_tree)' do
        assigns(:master_tree).should == master_tree
      end

      it "should find the correct master tree" do
        user.should have_received(:master_trees).with()
        master_trees.should have_received(:find).with(master_tree.to_param)
      end

    end
  end
end
