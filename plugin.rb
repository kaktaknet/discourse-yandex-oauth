# frozen_string_literal: true

# name: discourse-yandex-oauth
# about: Yandex ID OAuth2 authentication for Discourse
# version: 1.0.0
# authors: kaktaknet
# url: https://github.com/kaktaknet/discourse-yandex-oauth

# CRITICAL: enabled_site_setting MUST be before any require statements
enabled_site_setting :yandex_enabled

# Load custom OmniAuth strategy for Yandex
require_relative "lib/omniauth/strategies/yandex"

# Load authenticator class
require_relative "lib/yandex_authenticator"

# Register authentication provider
auth_provider(
  title: "Yandex",
  authenticator: YandexAuthenticator.new,
  message: "Войти с помощью Яндекса",
  frame_width: 920,
  frame_height: 800,
  icon: "fab-yandex"
)

# Register Yandex icon for login button
register_svg_icon "fab-yandex" if respond_to?(:register_svg_icon)

# Register Yandex auth button styles
register_asset "stylesheets/yandex-auth.scss"
