# frozen_string_literal: true

module Esi
  class AccessToken < OAuth2::AccessToken
    def initialize(*args)
      if args[0].is_a?(OAuth2::AccessToken)
        token = args[0]
        options = { refresh_token: token.refresh_token, expires_at: token.expires_at }
        super(token.client, token.token, options)
      else
        super(*args)
      end
    end

    def verify
      Esi::Response.new(get('/oauth/verify'))
    end
  end
end
