# frozen_string_literal: true
require "devise"
require "dry-configurable"
require "devise/fireauth/version"
require_relative "../firebase_id_token"

module Devise
  def self.fireauth
    yield(Devise::Fireauth.config)
    Devise::Fireauth.firebase_validator = FirebaseIDToken::Validator.new(aud: Devise::Fireauth.project_id)
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
    setting :project_id, reader: true

    # Firebase Validator
    mattr_accessor :firebase_validator
    @@firebase_validator = Fireauth.project_id
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
