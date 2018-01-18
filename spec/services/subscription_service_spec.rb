require 'rails_helper'

RSpec.describe SubscriptionService do
  let(:service) { described_class.new }

  describe '#create_subscription' do
    context 'when subscription already exists' do
      let!(:user) { FactoryBot.create(:user, :with_subscription) }
      let!(:subs_2) { FactoryBot.create(:contribution, date: Time.current, user: user) }
      let!(:subs_pending) { FactoryBot.create(:contribution, :pending, date: 1.month.from_now, user: user) }
      let(:expected) { { success: false, message: 'subscription already exists', code: HTTP_UNPROCESSABLE_ENTITY } }

      it 'returns already exists' do
        expect do
          result = service.create_subscription(user)
          expect(result).to eq expected
        end.not_to change(Contribution, :count)
      end
    end

    context 'when subscription does not exist' do
      let(:res) { { success: true, message: 'subscription created', code: HTTP_OK } }

      let!(:user) { FactoryBot.create(:user) }
      it 'returns subscription created' do
        allow_any_instance_of(BillingService).to receive(:call).and_return(res)
        expect do
          service.create_subscription(user)
          expect(Contribution.where(user_id: user.id, pending: true)).to exist
          expect(Contribution.where(user_id: user.id, pending: false)).to exist
        end.to change(Contribution, :count).by(2)
      end
    end
  end

  describe '#create_subscription' do
    context 'when billing had succed' do
      let(:res) { { success: true, message: 'subscription created', code: HTTP_OK } }
      let!(:user) { FactoryBot.create(:user, :with_subscription) }
      let!(:subs) { FactoryBot.create(:contribution, :pending, date: Time.current, user: user) }

      it 'updates pending attribute' do
        allow_any_instance_of(BillingService).to receive(:call).and_return(res)
        expect do
          service.create_payment(subs)
          expect(Contribution.where(user_id: user.id, pending: true)).to exist
          expect(Contribution.where(user_id: user.id, pending: false)).to exist
        end.to change(subs, :pending).from(true).to(false)
           .and change(Contribution, :count).by(1)
      end
    end

    context 'when billing had failed' do
      let(:res) { { success: false, message: 'subscription cancelled, insufficient funds', code: HTTP_UNPROCESSABLE_ENTITY } }
      let!(:user) { FactoryBot.create(:user, :with_subscription) }
      let!(:subs) { FactoryBot.create(:contribution, :pending, date: Time.current, user: user) }

      it 'updates pending attribute' do
        allow_any_instance_of(BillingService).to receive(:call).and_return(res)
        expect do
          service.create_payment(subs)
          expect(subs).to be_destroyed
          expect(Contribution.where(user_id: user.id, pending: true)).to exist
          expect(Contribution.where(user_id: user.id, pending: false)).not_to exist
        end.not_to change(Contribution, :count)
      end
    end
  end
end
