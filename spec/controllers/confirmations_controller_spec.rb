require 'spec_helper'

describe ConfirmationsController do
  context "on GET to #new" do
    let(:user) { Factory(:user) }

    before do
      get :new,
          :user_id => user.id,
          :token => user.confirmation_token
    end

    subject { controller }

    it { should redirect_to(trees_path) }
  end
end
