require 'spec_helper'

describe HomesController do

  context "signed out" do
    context "on GET to #show" do
      before do
        get :show
      end

      subject { controller }

      it { should redirect_to(new_user_session_url) }
    end
  end

  context "when signed in" do
    before do
      sign_in Factory(:user)
    end

    context "on GET to #show" do
      before do
        get :show
      end

      subject { controller }

      it { should redirect_to(master_trees_url) }
    end
  end

end
