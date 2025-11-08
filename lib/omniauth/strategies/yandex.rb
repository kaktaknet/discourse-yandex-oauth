# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Yandex < OmniAuth::Strategies::OAuth2
      option :name, 'yandex'

      option :client_options, {
        site: 'https://login.yandex.ru',
        authorize_url: 'https://oauth.yandex.ru/authorize',
        token_url: 'https://oauth.yandex.ru/token'
      }

      uid { raw_info['id'] }

      info do
        {
          email: raw_info['default_email'],
          name: "#{raw_info['first_name']} #{raw_info['last_name']}".strip,
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          login: raw_info['login']
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/info?format=json').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
