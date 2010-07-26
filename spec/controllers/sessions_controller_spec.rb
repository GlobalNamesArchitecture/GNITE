require 'spec_helper'

describe SessionsController do

  context "on POST to #create" do
    let(:user) { Factory(:email_confirmed_user) }

    before do
      post :create, :session => {
        :email    => user.email,
        :password => user.password
      }
    end

    subject { controller }

    it { should redirect_to(trees_path) }
  end
end
