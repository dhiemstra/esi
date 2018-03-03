# frozen_string_literal: true

module Esi
  class OAuth
    extend Forwardable

    attr_reader :access_token, :refresh_token, :expires_at
    def_delegators :token, :request, :get, :post, :delete, :patch, :put

    class << self
      def authorize_url(redirect_uri:, scopes: nil)
        scopes ||= Esi.config.scopes
        client.auth_code.authorize_url(scope: scopes.join(' '), redirect_uri: redirect_uri)
      end

      def obtain_token(code)
        ActiveSupport::Notifications.instrument('esi.oauth.obtain_token') do
          Esi::AccessToken.new(client.auth_code.get_token(code))
        end
      end

      def client
        @client ||= create_client
      end

      # @return [OAuth2::Client] new oAuth2 client instance with specified options
      def create_client(client_id: nil, client_secret: nil, site: nil)
        client_id ||= Esi.config.client_id
        client_secret ||= Esi.config.client_secret
        site ||= Esi.config.oauth_host

        OAuth2::Client.new(client_id, client_secret, site: site)
      end
    end

    def initialize(access_token:, refresh_token:, expires_at:, callback: nil, client: nil)
      raise Esi::Error, 'Callback should be a callable Proc' if callback && !callback.respond_to?(:call)

      @access_token = access_token
      @refresh_token = refresh_token
      @expires_at = expires_at
      @callback = callback if callback
      @client = client if client
    end

    private

    def client
      @client || OAuth.client
    end

    def token
      @token = Esi::AccessToken.new(client, @access_token,
                                    refresh_token: @refresh_token, expires_at: @expires_at)
      refresh_access_token if @token.expired?
      @token
    end

    def refresh_access_token
      ActiveSupport::Notifications.instrument('esi.oauth.refresh_token') do
        @token = @token.refresh!
        @access_token = @token.token
        @expires_at = @token.expires_at.integer? ? Time.at(@token.expires_at) : @token.expires_at
        @callback&.call(@access_token, @expires_at)
      end
    end
  end
end
