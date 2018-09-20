# frozen_string_literal: true

require "rails/railtie"
require_relative "middleware"

module Devise
  module Fireauth
    # Pluck to rails
    class Railtie < ::Rails::Railtie
      initializer "devise-fireauth-middleware" do |app|
        app.middleware.use Middleware

        config.after_initialize do
          Rails.application.reload_routes!
        end
      end
    end
  end
end
