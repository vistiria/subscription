class SubscriptionService
  def create_subscription(user)
    if user.subscription_exists?
      {
        success: false,
        message: 'subscription already exists',
        code:    HTTP_UNPROCESSABLE_ENTITY
      }
    else
      billing = BillingService.new(user).call
      if billing[:success]
        today = Date.today
        user.contributions.create(date: today)
        create_next_contribution(user, (today >> 1))
        user.update_attribute(:subscription_start, today)
      end
      billing
    end
  end

  def create_payment(contribution)
    user = contribution.user
    billing = BillingService.new(user).call
    create_next_contribution(user, next_billing_date(contribution))

    if billing[:success]
      contribution.update_attribute(:pending, false)
    else
      contribution.destroy
    end
  end

  private

  def create_next_contribution(user, date)
    user.contributions.create(date: date, pending: true)
  end

  def next_billing_date(contribution)
    start_date = contribution.user.subscription_start
    recent_date = contribution.date
    start_date_in_months = (start_date.year * 12 + start_date.month)
    recent_date_in_months = recent_date.year * 12 + recent_date.month
    months_gap = recent_date_in_months - start_date_in_months

    start_date >> (months_gap + 1)
  end
end
