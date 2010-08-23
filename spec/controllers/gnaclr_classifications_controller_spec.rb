require 'spec_helper'

describe GnaclrClassificationsController do
  context "when signed out" do
    describe "on GET to index" do
      before do
        get :index
      end

      subject { controller }

      it { should redirect_to(sign_in_url) }
      it { should set_the_flash.to(/sign in/) }
    end
  end

  context "signed in with some remote GNACLR classifications" do
    let(:user) { Factory(:email_confirmed_user) }

    before do
      sign_in_as(user)
    end

    describe "on GET to index" do
      let(:gnaclr_classifications) { 'fake classifications' }

      before do
        GnaclrClassification.stubs(:all => gnaclr_classifications)
        get :index
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template('index') }
      it { should assign_to(:gnaclr_classifications).with(gnaclr_classifications) }

      it "should find all the GnaclrClassifications" do
        GnaclrClassification.should have_received(:all).with()
      end
    end

    describe "on GET to show with a UUID passed as :id" do
      let(:gnaclr_classification) { 'fake classification' }

      before do
        GnaclrClassification.stubs(:find_by_uuid => gnaclr_classification)
        get :show, :id => 'the-uuid'
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template('show') }
      it { should assign_to(:gnaclr_classification).with(gnaclr_classification) }

      it "should find all the GnaclrClassifications" do
        GnaclrClassification.should have_received(:find_by_uuid).with('the-uuid')
      end

    end
  end
end
