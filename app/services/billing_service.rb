class BillingService
  class BillingHttpError < StandardError; end

  def initialize(user)
    @user = user
  end

  def call
    tries ||= 2
    response = http_get
    parse_billing_response(response)
  rescue BillingHttpError => e
    if (tries -= 1) > 0
      retry
    else
      {
        success: false,
        message: 'subscription failed, could not connect to billing service',
        code: e.message.to_i
      }
    end
  end

  private

  def parse_billing_response(response)
    paid = response[:paid]
    {
      success: paid,
      message: paid ? 'subscription created' : 'insufficient funds',
      code:    paid ? HTTP_OK : HTTP_UNPROCESSABLE_ENTITY
    }
  end

  def http_get
    auth = {:username => 'billing', :password => 'gateway'}
    response = HTTParty.get('http://localhost:4567/validate', :basic_auth => auth)

    if response.code == HTTP_OK
      response.parsed_response
    else
      raise BillingHttpError, response.code
    end
  end
end
