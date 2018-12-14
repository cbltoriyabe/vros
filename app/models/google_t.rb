class GoogleT < ApplicationRecord
  require 'yt'
  def getGoogleApiAccount()
    @gapi = GApiJSONload
    Yt.configure do |config|
      config.client_id = @gapi['web']['client_id']
      config.client_secret = @gapi['web']['client_secret']
      config.api_key = Rails.application.secrets.YoutubeApi
    end

    return
  end

  def GApiJSONload
    File.open("GoogleAPI.json") do |file|
      return JSON.parse(file.read)
    end
  end
end
