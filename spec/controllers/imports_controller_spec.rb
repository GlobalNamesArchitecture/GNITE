require 'spec_helper'

describe ImportsController do
  context "when signed out" do
    context "on GET to new" do
      before do
        get :new
      end

      subject { controller }

      it { should redirect_to(sign_in_url) }
      it { should set_the_flash.to(/sign in/) }
    end
  end

  context "signed in" do
    let(:user) { Factory(:email_confirmed_user) }

    before do
      sign_in_as(user)
    end

    context "on GET to new" do
      before do
        get :new
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template('new') }
    end
  end
end
