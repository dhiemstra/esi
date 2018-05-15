# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

# The Esi generator module
# @private
module Esi
  # Rails ESI Install Generator
  # @author Aaron Allen <hello@aaronmallen.me>
  # @version 0.1
  # @since 0.4.21
  # @private
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    source_root File.expand_path('templates', __dir__)
    desc 'Installs Esi.'

    # Called by rails generate
    # Installs esi.rb in config/initializers and
    # prints a helpful guide for next steps.
    def install
      template 'initializer.rb', 'config/initializers/esi.rb'
    end
  end
end
