namespace :subscriptions do
  desc 'subscription payment'
  task payment: :environment do
    Contribution.where(pending: true).where('date = ?', Date.today).includes(:user).find_each do |contr|
      service = SubscriptionService.new
      service.create_payment(contr)
    end
  end
end
