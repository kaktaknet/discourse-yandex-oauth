# frozen_string_literal: true

class YandexAuthenticator < Auth::ManagedAuthenticator
  def name
    'yandex'
  end

  def enabled?
    SiteSetting.yandex_enabled
  end

  def register_middleware(omniauth)
    omniauth.provider :yandex,
      SiteSetting.yandex_client_id,
      SiteSetting.yandex_client_secret
  end

  def after_authenticate(auth_token, existing_account: nil)
    result = super

    # Extract user data from auth_token.info (provided by custom strategy)
    result.email = auth_token.info.email
    result.email_valid = SiteSetting.yandex_email_verified
    result.username = sanitize_username(auth_token.info.login || auth_token.info.first_name)
    result.name = auth_token.info.name

    # Store additional Yandex-specific data
    result.extra_data = {
      yandex_user_id: auth_token.uid.to_s,
      yandex_login: auth_token.info.login,
      yandex_first_name: auth_token.info.first_name,
      yandex_last_name: auth_token.info.last_name
    }

    result
  end

  def primary_email_verified?(auth_token)
    SiteSetting.yandex_email_verified
  end

  private

  def sanitize_username(username)
    return generate_random_username if username.blank?

    # Remove invalid characters and limit length
    # Discourse allows: a-z, A-Z, 0-9, _, - (max 20 chars)
    username = username.gsub(/[^a-zA-Z0-9_-]/, '_')
    username = username[0...20]

    # Ensure username is not empty after sanitization
    username = generate_random_username if username.blank?

    # Ensure uniqueness
    ensure_unique_username(username)
  end

  def ensure_unique_username(username)
    original = username
    counter = 1

    # Append counter until we find unique username
    while User.exists?(username: username)
      # Calculate available space for counter
      max_base_length = 20 - "_#{counter}".length
      base = original[0...max_base_length]
      username = "#{base}_#{counter}"
      counter += 1

      # Safety check to prevent infinite loop
      break if counter > 9999
    end

    username
  end

  def generate_random_username
    "yandex_user_#{SecureRandom.hex(6)}"
  end
end
