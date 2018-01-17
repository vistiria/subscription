class SubscriptionService
	def initialize(user)
    @user = user
  end
  def create_subscription
    if @user.subscription_exists?
      {
        success: false,
        message: 'subscription already exists',
        code:    HTTP_UNPROCESSABLE_ENTITY
      }
    else
      billing = BillingService.new(@user).call
      if billing[:success]
        today = Date.today
        @user.contributions.create(date: today)
        @user.contributions.create(date: (today >> 1), pending: true)
        @user.update_attribute(:subscription_start, today)
      end
      billing
    end
  end
end