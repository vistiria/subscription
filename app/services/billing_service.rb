class BillingService
  def initialize(user)
    @user = user
  end

  def call
    {
      success: true,
      message: 'subscription created',
      code:    HTTP_OK
    }
  end
end