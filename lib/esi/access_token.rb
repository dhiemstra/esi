module Esi
  class AccessToken < OAuth2::AccessToken
    def verify_token(token)
      token.get("/oauth/verify")
    end
  end
end
