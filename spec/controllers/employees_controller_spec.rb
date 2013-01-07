require 'spec_helper'

describe EmployeesController do
  include AccessSpecHelper

  before(:all) { @partner = create(:partner) }

  after(:all) do
    @partner.user.destroy
    @partner.destroy
  end

  before(:each) { login }

  describe :index do
    before { get :index, partner_id: @partner }

    it 'should assign @partner' do
      expect(assigns(:partner)).to eq(@partner)
    end
  end

  describe :create do
    before(:all) { grant_access(:partners) }
    after(:all) { revoke_access(:partners) }

    def send_request
      post :create, partner_id: @partner, employee: params
    end

    context 'when invalid data' do
      let(:params) { {} }

      it 'should not save the record' do
        expect { send_request }.to_not change { Employee.count }
      end
    end

    context 'when valid data' do
      let(:params) { { name: 'Doe', prename: 'John' } }

      it 'should save the record' do
        expect { send_request }.to change { Employee.count }.by(1)
      end

      it 'should attach the employee to the partner' do
        expect { send_request }.to change { @partner.employees(true).count }.by(1)
      end
    end
  end

  describe :update do
    before(:all) do
      grant_access(:partners)
      @employee = create(:employee, partner: @partner)
    end

    after(:all) do
      revoke_access(:partners)
      @employee.destroy
    end

    before { put :update, partner_id: @partner, id: @employee, employee: params }

    subject { @employee.reload }

    context 'when invalid data' do
      let(:params) { { name: '', prename: 'griffin' } }

      it 'should not save the record' do
        expect(subject.name).to_not be_blank
      end
    end

    context 'when data is valid' do
      let(:params) { { prename: 'peter', name: 'griffin' } }

      it 'should save the record' do
        expect(subject.prename).to eq('peter')
        expect(subject.name).to eq('griffin')
      end
    end
  end

  describe :destroy do
    before(:all) do
      grant_access(:partners)
      @employee = create(:employee, partner: @partner)
    end

    after(:all) do
      revoke_access(:partners)
      @employee.destroy
    end

    before { delete :destroy, partner_id: @partner, id: @employee }

    subject { @employee }

    it 'should destroy the record' do
      expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
