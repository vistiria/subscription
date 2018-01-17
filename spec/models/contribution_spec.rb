require 'rails_helper'

RSpec.describe Contribution, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:user) }
  it { should validate_inclusion_of(:pending).in_array([true, false]) }
end
