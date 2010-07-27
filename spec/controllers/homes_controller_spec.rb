require 'spec_helper'

describe HomesController do

  context "signed out" do
    context "on GET to #show" do
      before do
        get :show
      end

      subject { controller }

      it { should redirect_to(sign_in_url) }
    end
  end

  context "when signed in" do
    before do
      @user = Factory(:email_confirmed_user)
      sign_in_as(@user)
    end

    context "on GET to #show" do
      before do
        get :show
      end

      subject { controller }

      it { should redirect_to(trees_url) }
    end
  end

end
