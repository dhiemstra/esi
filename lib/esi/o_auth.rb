module Esi
  class OAuth
    SCOPES = %w(
      esi-assets.read_assets.v1
      esi-bookmarks.read_character_bookmarks.v1
      esi-clones.read_clones.v1
      esi-skills.read_skillqueue.v1
      esi-skills.read_skills.v1
      esi-wallet.read_character_wallet.v1
      esi-fleets.read_fleet.v1
      esi-fleets.write_fleet.v1
      esi-killmails.read_killmails.v1
      esi-location.read_location.v1
      esi-location.read_ship_type.v1
      esi-mail.organize_mail.v1
      esi-mail.read_mail.v1
      esi-mail.send_mail.v1
      esi-markets.structure_markets.v1
      esi-search.search_structures.v1
      esi-universe.read_structures.v1
      esi-ui.open_window.v1
      esi-ui.write_waypoint.v1
      esi-corporations.read_corporation_membership.v1
      esi-corporations.read_structures.v1
      esi-corporations.write_structures.v1
    )

    class << self
      def authorize_url(account_id=nil)
        account = account_id ? Account.find(account_id) : Account.default
        callback = config.eve_callback + "?account_id=#{account_id}"
        client.auth_code.authorize_url(scope: SCOPES.join(' '), redirect_uri: callback)
      end

      def obtain_token(code)
        client.auth_code.get_token(code)
      end

      def client
        @client ||= OAuth2::Client.new(
          config.eve_client_id, config.eve_secret_key,
          { site: 'https://login.eveonline.com/oauth/authorize' }
        )
      end

      def config
        @config ||= OpenStruct.new(YAML::load_file(Rails.root.join('config', 'eve.yml'))[Rails.env])
      end
    end

    attr_reader :access_token, :refresh_token, :expires_at

    delegate :request, :get, :post, :delete, :patch, :put, to: :token

    def initialize(access_token:, refresh_token:, expires_at:, callback: nil)
      if callback && !callback.respond_to?(:call)
        raise Esi::Error.new("Callback should be a callable Proc")
      end

      @access_token = access_token
      @refresh_token = refresh_token
      @expires_at = expires_at
      @callback = callback if callback
    end

    private

    def token
      @token = OAuth2::AccessToken.new(OAuth.client, @access_token, {
        refresh_token: @refresh_token, expires_at: @expires_at
      })
      refresh_access_token if @token.expired?
      @token
    end

    def refresh_access_token
      @token = @token.refresh!
      @access_token = @token.token
      @expires_at = @token.expires_at.integer? ? Time.at(@token.expires_at) : @token.expires_at
      @callback.call(@access_token, @expires_at) if @callback
    end
  end
end
