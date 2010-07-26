require 'spec_helper'

describe TreesController do

  context "on GET to #index" do
    before do
      get :index
    end

    subject { controller }

    it { should respond_with(:success) }
    it { should render_template(:index) }
  end

end
