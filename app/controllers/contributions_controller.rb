class ContributionsController < ApplicationController
  before_action :authenticate_user!

  def create
    contribution = SubscriptionService.new.create_subscription(current_user)
    if contribution[:success]
      render_subscription_success(contribution[:message])
    else
      render_subscription_error(contribution[:message], contribution[:code])
    end
  end

  def index
    if current_user.subscription_exists?
      subscriptions = current_user.contributions.order(date: :asc).pluck(:date)
      next_subscription = subscriptions.pop

      render json: {
        subscription_dates: subscriptions,
        next_billing_date: next_subscription
      }
    else
      render_subscription_error('subscription doesn\'t exist', HTTP_UNPROCESSABLE_ENTITY)
    end
  end

  private

  def render_subscription_error(message, code)
    render json: {
      status: 'error',
      errors: message
    }, status: code
  end

  def render_subscription_success(message)
    render json: {
      status: 'success',
      data:   message
    }
  end
end
