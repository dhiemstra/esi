# frozen_string_literal: true

# Specify a custom log level
Esi.config.log_level = :info

# Specify a custom log path
Esi.config.log_target = Rails.root.join('log', 'esi.log')

# Specify a custom logger
Esi.config.logger = Rails.logger

# Set esi api version to dev
Esi.config.api_version = :latest

# Save all raw JSON responses in this folder
Esi.config.response_log_path = Rails.root.join('tmp', 'esi')

# Set Esi Cache to Rails.cache
Esi.config.cache = Rails.cache

# Set Esi Client Id
Esi.config.client_id = ENV['ESI_CLIENT_ID']

# Set Esi Client Secret
Esi.config.client_secret = ENV['ESI_CLIENT_SECRET']
