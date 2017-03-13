# Esi

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/esi`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'esi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install esi

## Usage

    esi = Esi::Client.new(token: 'YOUR_TOKEN', refresh_token: 'REFRESH_TOKEN', token_expires_at: EXPIRE_TIMESTAMP)
    esi.character()

### You can optionally specify a callback that will be executed after a new token has been received using the refresh token

    esi.refresh_callback = ~> (token, expires_at) {
      # save new token & expires at
    }

## Authentication

Register your application on [https://developers.eveonline.com/applications].
Add your client id and secret in an initializer or so.

    Esi.config.client_id = 'APP_CLIENT_ID'
    Esi.config.client_secret = 'APP_CLIENT_SECRET'

## Configuration

Create a file `config/initializers/esi.rb` with the following options:

    # Specify a custom log level
    Esi.config.log_level = :debug

    # Specify a custom log path
    Esi.config.log_target = Rails.root.join('log', 'esi.log')

    # Specify a custom logger
    Esi.config.logger = Rails.logger

    # Set esi api version to dev
    Esi.config.api_version = :dev

    # Save all responses in this folder
    Esi.config.response_log_path = Rails.root.join('tmp', 'esi')
