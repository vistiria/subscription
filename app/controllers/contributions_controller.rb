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
