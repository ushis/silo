require 'spec_helper'

describe LoginController do
  include AccessSpecHelper

  before(:each) { @user.reload }

  describe 'GET welcome' do
    context 'for logged in users' do
      before(:each) { get :welcome }

      it 'should have a 200 status code' do
        expect(response.code).to eq('200')
      end

      it 'should set a title' do
        expect(assigns(:title)).to_not be_blank
      end
    end

    context 'for already logged in users' do
      before(:each) do
        login
        get :welcome
      end

      it 'should redirect to root' do
        expect(response).to redirect_to(:root)
      end
    end
  end

  describe 'POST login' do
    context 'for not logged in users' do
      context 'and invalid credentials' do
        before(:each) do
          post :login, username: @user.username, password: 'wrong'
        end

        it 'should render welcome' do
          expect(response).to render_template(:welcome)
        end

        it 'should set a alert flash' do
          expect(flash.now[:alert]).to_not be_blank
        end
      end

      context 'and valid credentials' do
        before(:each) do
          @login_hash = @user.login_hash
          post :login, @credentials
        end

        it 'should set a new login hash' do
          @user.reload
          expect(@user.login_hash).to_not eq(@login_hash)
          expect(session[:login_hash]).to eq(@user.login_hash)
        end

        it 'should redirect to root' do
          expect(response).to redirect_to(:root)
        end
      end
    end

    context 'for logged in users' do
      before(:each) do
        login
        post :login
      end

      it 'should redirect to root' do
        expect(response).to redirect_to(:root)
      end
    end
  end

  describe 'DELETE logout' do
    context 'for not logged in users' do
      before(:each) { delete :logout }

      it 'should redirect to welcome' do
        expect(response).to redirect_to(controller: :login, action: :welcome)
      end
    end

    context 'for logged in users' do
      before(:each) do
        login
        delete :logout
      end

      it 'should unset the login_hash' do
        expect(session[:login_hash]).to be_nil
      end

      it 'should render welcome' do
        expect(response).to render_template(:welcome)
      end

      it 'should set the title' do
        expect(assigns(:title)).to_not be_blank
      end
    end
  end
end
