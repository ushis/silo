require 'spec_helper'

describe User do
  describe :validations do
    before(:all) { @u = create(:user_with_login_hash) }
    after(:all)  { @u.destroy }

    %w(password username name prename email).each do |attr|
      it { should validate_presence_of(attr) }
    end

    %w(username email login_hash).each do |attr|
      it { should validate_uniqueness_of(attr) }
    end

    ['Uppercase', 'white space', 'strange_*#'].each do |value|
      it { should_not allow_value(value).for(:username) }
    end

    it { should allow_value('lowercase1and1numbers304').for(:username) }
  end

  describe :associations do
    it { should have_many(:experts) }
    it { should have_many(:partners) }
    it { should have_many(:lists) }

    it { should have_one(:privilege).dependent(:destroy) }
    it { should belong_to(:current_list).class_name(:List) }
  end

  describe :delegations do
    [:access?, :admin?].each do |method|
      it { should delegate_method(method).to(:privilege) }
    end
  end

  describe :check_old_password_before_save do
    before { subject.check_old_password_before_save }

    it 'should set the check_old_password_before_save flag to true' do
      expect(subject.check_old_password_before_save?).to be_true
    end
  end

  describe :check_old_password_validation do
    subject { create(:user, password: 'secret') }

    before do
      subject.check_old_password_before_save
      subject.password = 'super new secure password'
    end

    context 'when password changed without old password' do
      it 'should not be valid' do
        expect(subject).to_not be_valid
        expect(subject.errors[:password_old]).to_not be_empty
      end
    end

    context 'when password changed and old password is correct' do
      before { subject.password_old = 'secret' }

      it 'should be valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe :refresh_login_hash do
    subject { build(:user_with_login_hash) }

    it 'should be a 160 bit hexdigest' do
      expect(subject.refresh_login_hash).to match(%r{\A[a-f0-9]{40}\z})
    end

    it 'should change the login hash' do
      expect { subject.refresh_login_hash }.to change { subject.login_hash }
    end

    it 'should be the same as the assigned login_hash' do
      expect(subject.refresh_login_hash).to eq(subject.login_hash)
    end
  end

  describe :refresh_login_hash! do
    subject { build(:user_with_login_hash) }

    it 'should be true' do
      expect(subject.refresh_login_hash!).to be_true
    end

    it 'should save the record' do
      expect(subject).to be_new_record
      subject.refresh_login_hash!
      expect(subject).to be_persisted
    end

    it 'should change the login_hash' do
      expect { subject.refresh_login_hash! }.to change { subject.login_hash }
    end
  end

  describe :full_name do
    subject { build(:user, prename: 'John', name: 'Doe').full_name }

    it 'should be a combination of name and prename' do
      expect(subject).to eq('John Doe')
    end
  end

  describe :to_s do
    subject { build(:user) }

    it 'should be the users full_name' do
      expect(subject.to_s).to eq(subject.full_name)
    end
  end
end
