require 'spec_helper'

describe ProfileController do
  include AccessSpecHelper

  before(:each) { login }

  describe :edit do
    before(:each) { get :edit }

    context 'when normal user' do
      it 'should assign @user with the current user' do
        expect(assigns(:user)).to eq(@user)
      end
    end

    context 'when admin' do
      before(:all) { grant_access(:admin) }
      after(:all) { revoke_access(:admin) }

      it 'should redirect to edit' do
        expect(response).to redirect_to(edit_user_url(@user))
      end
    end
  end

  describe :update do
    before(:each) { put :update, user: params }

    let(:params) { {} }

    it 'should render :edit' do
      expect(response).to render_template(:edit)
    end

    it 'should assign the current user' do
      expect(assigns(:user)).to eq(@user)
    end

    context 'when everything is fine' do
      let(:params) { { name: 'Something valid' } }

      it 'should update the current user' do
        expect(@user.reload.name).to eq('Something valid')
      end
    end

    context 'when updating the password' do
      context 'and providing a wrong old password' do
        let(:params) { { password: 'new password', password_old: 'wrong' } }

        it 'should not update the user' do
          expect(assigns(:user)).to be_changed
          expect(@user.reload.authenticate(@credentials[:password])).to eq(@user)
        end
      end

      context 'and providing correct old password' do
        let(:params) { { password: 'new password', password_old: @credentials[:password] } }

        it 'should update the users password' do
          expect(assigns(:user)).to_not be_changed
          expect(@user.reload.authenticate('new password')).to eq(@user)
        end
      end
    end
  end
end
