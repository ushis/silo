require 'spec_helper'

describe User do
  context 'validations' do
    [:password, :username, :name, :prename, :email].each do |attr|
      it "must have a #{attr}" do
        user = User.new
        user.should_not be_valid
        user.errors[attr].should_not be_empty
      end
    end

    [:username, :email, :login_hash].each do |attr|
      it "must have a unique #{attr}" do
        value = 'somevalidstring'
        create(:user, attr => value)

        user = build(:user, attr => value)
        user.should_not be_valid
        user.errors[attr].should_not be_empty
      end
    end

    it 'must have a valid username' do
      ['Uppercase', 'white space', 'strange_*#'].each do |invalid|
        user = build(:user, username: invalid)
        user.should_not be_valid
        user.errors[:username].should_not be_empty
      end

      user = build(:user, username: 'lowercase1and1numbers304')
      user.errors[:username].should be_empty
    end
  end

  context 'associations' do
    it { should have_many(:experts) }
    it { should have_many(:lists) }

    it { should have_one(:privilege).dependent(:destroy) }
    it { should belong_to(:current_list).class_name(:List) }
  end

  context 'delegations' do
    [:access?, :admin?, :privileges=].each do |method|
      it { should delegate_method(method).to(:privilege) }
    end
  end

  describe 'refresh_login_hash' do
    it 'should set a brand new login_hash' do
      user = build(:user_with_login_hash)
      user.login_hash.should_not be_blank
      hash = user.login_hash
      user.refresh_login_hash
      user.login_hash.should_not be_blank
      user.login_hash.should_not == hash
      user.login_hash_changed?.should be_true
    end
  end

  describe 'refresh_login_hash!' do
    it 'should set a brand new login_hash and save the record' do
      user = create(:user_with_login_hash)
      user.login_hash.should_not be_blank
      hash = user.login_hash
      user.refresh_login_hash!
      user.login_hash.should_not be_blank
      user.login_hash.should_not == hash
      user.login_hash_changed?.should be_false
    end
  end

  describe 'full_name' do
    it 'should be a combination of name and prename' do
      user = build(:user, prename: 'John', name: 'Doe')
      user.full_name.should == 'John Doe'
    end
  end

  describe 'to_s' do
    it 'should be the users full_name' do
      user = build(:user)
      user.to_s.should == user.full_name
    end
  end
end
