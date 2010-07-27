require 'spec_helper'

describe HomesController do

  context "on GET to #show" do
    before do
      get :show
    end

    subject { controller }

    it { should redirect_to(sign_in_path) }
  end

end
