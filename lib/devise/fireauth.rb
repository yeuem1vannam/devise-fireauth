# frozen_string_literal: true
require "devise"
require "dry-configurable"
require "devise/fireauth/version"

module Devise
  def self.fireauth
    yield(Devise::Fireauth.config)
  end

  warden do |manager|
    manager.strategies.add(:firebase_authenticatable, Devise::Strategies::FirebaseAuthenticatable)
    manager.default_strategies(scope: :user).unshift :firebase_authenticatable
  end
  add_module :firebase_authenticatable, controller: :sessions, route: { session: :routes }

  module Fireauth
    extend Dry::Configurable

    setting :api_key, reader: true
    setting :token_key, :id_token, reader: true
    # TODO
    # - project_id: for verifying aud / iss
  end

  # Those modules must be loaded after Fireauth configuration done
  module Models
    autoload :FirebaseAuthenticatable,
      "devise/fireauth/models/firebase_authenticatable"
  end

  module Strategies
    autoload :FirebaseAuthenticatable,
      "devise/fireauth/strategies/firebase_authenticatable"
  end

  # TODO: verify the correct way to add strategies to warden
  warden do |manager|
    manager.strategies.add(:firebase_authenticatable, Devise::Strategies::FirebaseAuthenticatable)
  end
  add_module :firebase_authenticatable, controller: :sessions, route: { session: :routes }
end
