require 'spec_helper'

describe UsersController do
  include AccessSpecHelper

  before(:all) { grant_access(:admin) }
  after(:all) { revoke_access(:admin) }

  before(:each) { login }

  describe :index do
    before(:each) { get :index }

    it 'should assign @users' do
      expect(assigns(:users)).to_not be_empty
      expect(assigns(:users)).to be_all { |u| u.is_a?(User) }
    end
  end

  describe :new do
    before(:each) { get :new }

    it 'should assign @user' do
      expect(assigns(:user)).to be_a(User)
      expect(assigns(:user)).to be_new_record
    end

    it 'should render :form' do
      expect(response).to render_template(:form)
    end
  end

  describe :create do
    before(:each) { post :create, user: params }

    context 'when valid params' do
      let(:params) do
        { username: 'jd',
          name: 'Doe',
          prename: 'John',
          email: 'jonny@doe.com',
          password: 'secret',
          password_confirmation: 'secret' }
      end

      it 'should create a new user' do
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
        expect(assigns(:user).username).to eq('jd')
      end

      it 'should redirect to :index' do
        expect(response).to redirect_to(users_url)
      end
    end

    context 'when invalid params' do
      let(:params) { { prename: 'Mr.', name: 'Invalid' } }

      it 'should not save the user' do
        expect(assigns(:user)).to be_new_record
      end

      it 'should render :form' do
        expect(response).to render_template(:form)
      end
    end
  end

  describe :edit do
    before(:each) { get :edit, id: @user }

    it 'should assign @user' do
      expect(assigns(:user)).to eq(@user)
    end

    it 'should render :form' do
      expect(response).to render_template(:form)
    end
  end

  describe :update do
    before(:all) { @u = create(:user) }
    after(:all) { @u.destroy }

    before(:each) do
      put :update, id: id, user: params
    end

    let(:id) { @u }

    context 'when params invalid' do
      let(:params) { { username: '' } }

      it 'should not save the record' do
        expect(assigns(:user)).to be_changed
        expect(assigns(:user)).to_not be_valid
      end

      it 'should render :form' do
        expect(response).to render_template(:form)
      end
    end

    context 'when params valid' do
      let(:params) { { username: 'username123' } }

      it 'should save the record' do
        expect(assigns(:user)).to_not be_changed
        expect(@u.reload.username).to eq('username123')
      end

      it 'should redirect to users_url' do
        expect(response).to redirect_to(users_url)
      end
    end
  end

  describe :destroy do
    before(:each) { @u = create(:user) }

    context 'when action is not confirmed with password' do
      before(:each) { delete :destroy, id: @u }

      it 'should not delete the user' do
        expect(User.exists?(@u)).to be_true
      end

      it 'should redirect' do
        expect(response).to be_redirect
      end
    end

    context 'when user is current_user' do
      before(:each)  do
        delete :destroy, id: @user, password: @credentials[:password]
      end

      it 'should not delete the user' do
        expect(User.exists?(@user)).to be_true
      end

      it 'should redirect to users_url' do
        expect(response).to redirect_to(users_url)
      end
    end

    context 'when everything is fine' do
      before(:each) do
        delete :destroy, id: @u, password: @credentials[:password]
      end

      it 'should delete the user' do
        expect(User.exists?(@u)).to be_false
      end

      it 'should redirect to users_url' do
        expect(response).to redirect_to(users_url)
      end
    end
  end
end
