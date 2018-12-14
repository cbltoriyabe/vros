class Auth < ApplicationRecord
  devise :trackable, :omniauthable, omniauth_providers: %i(google)

  protected
  def self.find_for_google(auth)
    user = Auth.find_by(email: auth.info.email)

    unless Auth
      user = Auth.create(name:     auth.info.name,
                         provider: auth.provider,
                         uid:      auth.uid,
                         token:    auth.credentials.token,
                         password: Devise.friendly_token[0, 20],
                         meta:     auth.to_yaml)
    end
    user
  end
end
