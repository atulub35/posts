class JsonAuthenticatableStrategy < Warden::Strategies::Base
  def valid?
    request.format.json?
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