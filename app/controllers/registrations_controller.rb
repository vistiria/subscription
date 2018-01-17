class RegistrationsController < DeviseTokenAuth::RegistrationsController

  protected

  def render_create_success
    render json: {
      status: 'success',
      data:   'user has been created, please log in'
    }
  end
end
