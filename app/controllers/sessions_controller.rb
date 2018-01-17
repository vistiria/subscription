  class SessionsController < DeviseTokenAuth::SessionsController

    protected

    def render_create_success
      render json: {
        status: 'success'
      }
    end
  end
  