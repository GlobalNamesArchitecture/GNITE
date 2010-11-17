require 'spec_helper'

describe Your::PasswordsController do

  context "when signed in" do
    before do
      @user = Factory(:email_confirmed_user)
      sign_in_as(@user)
    end

    context "on GET to #edit" do
      before do
        get :edit
      end

      subject { controller }

      it 'should assign_to(:user)' do
        assigns(:user).should_not be_nil
      end
      it { should render_template('your/passwords/edit') }
    end

    context "on PUT to successful #update" do
      before do
        @controller.stubs(:current_user).returns(@user)
        @user.stubs(:update_password).returns(true)

        put :update, :user => {
          :password => "newpassword",
          :password_confirmation => "newpassword"
        }
      end

      subject { controller }

      it "should update the user's password" do
        @user.should have_received(:update_password).with("newpassword", "newpassword")
      end

      it { should redirect_to(root_url) }
      it { should set_the_flash.to(/password changed/i) }
    end

    context "on PUT to failing #update" do
      before do
        @controller.stubs(:current_user).returns(@user)
        @user.stubs(:update_password).returns(false)

        put :update, :user => {
          :password => "newpassword",
          :password_confirmation => "newpassword"
        }
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template(:edit) }
      it 'should assign_to(:user)' do
        assigns(:user).should_not be_nil
      end
    end
  end

end
