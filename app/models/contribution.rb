class Contribution < ApplicationRecord
  belongs_to :user

  validates :date, :user, presence: true
  validates :pending, inclusion: [true, false]
end
