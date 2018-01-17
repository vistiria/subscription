require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many :contributions }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:encrypted_card_number) }
  it { is_expected.to validate_presence_of(:email) }

  describe '#subscription_exists?' do
    context 'when user is not subscribed' do
      let(:user) { FactoryBot.build(:user) }

      it 'returns false' do
        expect(user.subscription_exists?).to be false
      end
    end

    context 'when user is subscribed' do
    let(:user) { FactoryBot.build(:user, :with_subscription) }
      it 'returns true' do
        expect(user.subscription_exists?).to be true
      end
    end
  end
end
