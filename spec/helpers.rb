module Helpers
  def token_sign_in(user)
    auth_headers = user.create_new_auth_token
    request.headers.merge!(auth_headers)
  end
end
