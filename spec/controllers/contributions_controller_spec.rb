require 'rails_helper'

RSpec.describe ContributionsController, type: :controller, api_controller: true do
  let(:user) { FactoryBot.build(:user) }

  describe 'POST #create' do
    before do
      token_sign_in(user)
    end
    context 'when subscription is created' do
      let(:subscription) { { success: true, message: 'subscription created', code: HTTP_OK } }
      let(:expected_resp) { "{\"status\":\"success\",\"data\":\"subscription created\"}" }
      before do
        allow_any_instance_of(SubscriptionService).to receive(:create_subscription).and_return(subscription)
      end
      it 'renders subscription success' do
        post :create
        expect(response).to be_success
        expect(response.body).to eq expected_resp
      end
    end

    context 'when subscription is not created' do
      let(:subscription) { { success: false, message: 'insufficient funds', code: HTTP_UNPROCESSABLE_ENTITY } }
      let(:expected_resp) { "{\"status\":\"error\",\"errors\":\"insufficient funds\"}" }
      before do
        allow_any_instance_of(SubscriptionService).to receive(:create_subscription).and_return(subscription)
      end
      it 'renders subscription error' do
        post :create
        expect(response).to have_http_status(HTTP_UNPROCESSABLE_ENTITY)
        expect(response.body).to eq expected_resp
      end
    end
  end

  describe 'GET #index' do
    context 'when subscription does not exist' do
      let(:expected_resp) { "{\"status\":\"error\",\"errors\":\"subscription doesn't exist\"}" }
      before do
        token_sign_in(user)
      end
      it 'renders subscription error' do
        get :index
        expect(response).to have_http_status(HTTP_UNPROCESSABLE_ENTITY)
        expect(response.body).to eq expected_resp
      end
    end

    context 'when subscription exists' do
      let!(:user) { FactoryBot.create(:user, :with_subscription) }
      let!(:subs_1) { FactoryBot.create(:contribution, date: 2.months.ago, user: user) }
      let!(:subs_2) { FactoryBot.create(:contribution, date: Time.current, user: user) }
      let!(:subs_pending) { FactoryBot.create(:contribution, :pending, date: 1.month.from_now, user: user) }

      let(:expected_resp) { "{\"subscription_dates\":[\"#{subs_1.date}\",\"#{subs_2.date}\"],\"next_billing_date\":\"#{subs_pending.date}\"}" }
      before do
        token_sign_in(user)
      end
      it 'renders valid subscriptions and next billing date' do
        get :index
        expect(response).to be_success
        expect(response.body).to eq expected_resp
      end
    end
  end
end
