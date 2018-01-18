require 'rails_helper'

RSpec.describe BillingService do
  describe '#call' do
    let!(:user) { FactoryBot.create(:user) }
    let(:service) { described_class.new(user) }

    context 'external billing api sends success' do
      let(:res) { { success: true, message: 'subscription created', code: HTTP_OK } }
      it 'returns insufficient funds' do
        allow_any_instance_of(described_class).to receive(:http_get).and_return(true)

        result = service.call
        expect(result).to eq res
      end
    end

    context 'when billing api is not available' do
      let(:res) { { success: false, message: 'subscription failed, could not connect to billing service', code: HTTP_INTERNAL_ERROR } }
      it 'returns failure' do
        allow_any_instance_of(described_class).to receive(:http_get)
                                              .and_raise(BillingService::BillingHttpError, HTTP_INTERNAL_ERROR)

        result = service.call
        expect(result).to eq res
      end
    end

    context 'external billing api sends decline' do
      let(:res) { { success: false, message: 'insufficient funds', code: HTTP_UNPROCESSABLE_ENTITY } }
      it 'returns insufficient funds' do
        allow_any_instance_of(described_class).to receive(:http_get).and_return(false)

        result = service.call
        expect(result).to eq res
      end
    end
  end
end
