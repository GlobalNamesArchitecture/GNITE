require 'spec_helper'

describe HomesController do

  context "on GET to #show" do
    before do
      get :show
    end

    subject { controller }

    it { should respond_with(:success) }
    # it do 
    #   get :show
    #   response.status.should == 200
    #   # puts subject.methods.sort.inspect
    #   #should respond_with(:success)
    #   # subject.status.should == 200
    # end
  end

end
