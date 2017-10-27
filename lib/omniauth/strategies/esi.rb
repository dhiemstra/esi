require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Esi < OmniAuth::Strategies::OAuth2
      option :name, 'esi'
      option :client_options, { site: ::Esi.config.oauth_host, verify_url: '/oauth/verify' }
      option :authorize_options, [:scope]

      uid { extra_info[:character_id] }

      info do
        {
          character_id:         extra_info[:character_id],
          character_name:       extra_info[:character_name],
          character_owner_hash: extra_info[:character_owner_hash],
          token_type:           raw_info[:token_type]
        }
      end

      credentials do
        hash = {token: access_token.token}
        hash.merge!(refresh_token: access_token.refresh_token) if access_token.refresh_token
        hash.merge!(expires_at: access_token.expires_at) if access_token.expires?
        hash.merge!(expires: access_token.expires?)
        hash.merge!(scopes: extra_info[:scopes].split(' ')) if extra_info[:scopes]
        hash
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.params)
      end

      def extra_info
        @extra_info ||= deep_symbolize(access_token.get(options.client_options.verify_url).parsed.transform_keys!(&:underscore))
      end

      def authorize_params
        params = super
        params = params.merge(request.params) unless OmniAuth.config.test_mode
        params[:scope] = params[:scope].join(' ') if params[:scope].is_a?(Array)
        params[:redirect_uri] = callback_url
        params
      end

      def request_phase
        redirect client.auth_code.authorize_url(authorize_params)
      end

      def build_access_token
        verifier = request.params['code']
        client.auth_code.get_token(verifier, token_params)
      end
    end
  end
end
