# Esi
[![Gem Version](https://badge.fury.io/rb/esi.svg)](https://badge.fury.io/rb/esi)
[![TravisCI build status](https://travis-ci.org/dhiemstra/esi.svg?branch=master)](https://travis-ci.org/dhiemstra/esi)
[![Maintainability](https://api.codeclimate.com/v1/badges/ea56ec4e1a9933642005/maintainability)](https://codeclimate.com/github/dhiemstra/esi/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ea56ec4e1a9933642005/test_coverage)](https://codeclimate.com/github/dhiemstra/esi/test_coverage)

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

    esi = Esi::Client.new(token: 'YOUR_TOKEN', refresh_token: 'REFRESH_TOKEN', expires_at: EXPIRE_TIMESTAMP)
    esi.character()

### You can optionally specify a callback that will be executed after a new token has been received using the refresh token

    esi.refresh_callback = -> (token, expires_at) {
      # save new token & expires at
    }

## Authentication

Register your application on [https://developers.eveonline.com/applications].
Add your client id and secret in an initializer or so.

    Esi.config.client_id = 'APP_CLIENT_ID'
    Esi.config.client_secret = 'APP_CLIENT_SECRET'

## Configuration in Rails

Install the initializer with `rails generator esi:install` and modify
`config/initializers/esi.rb`.

### Caching

ESI will cache API requests that auto expire based on the `Expires-At` header returned by ESI. By default [`ActiveSupport::Cache::MemoryStore`](http://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html) is used. When using Rails you can configure ESI to use the cache configured in your app by setting the `cache` config variable.

    Esi.config.cache = Rails.cache

To disable caching you can set this value to `nil`.
