class JsonAuthenticatableStrategy < Warden::Strategies::Base
  def valid?
    request.format.json? && 
    request.path.start_with?('/users/sign_in')
  end

  def authenticate!
    user = User.find_by(email: params[:user][:email])
    if user&.valid_password?(params[:user][:password])
      success!(user)
    else
      fail!
    end
  end
end 