require "warden"
require "pry"

module Warden
  module Fireauth
    class Strategy < Warden::Strategies::Base
      def valid?
        !token.nil?
      end

      def store?
        false
      end

      def authenticate!
        user = User.firebase_authentication({id_token: token})
        success!(user)
      rescue JWT::DecodeError => exception
        fail!(exception.message)
      end

      def authenticate
        user = User.firebase_authentication({id_token: token})
        # If authenticated, stop immediately - or continue
        user ? success!(user) : fail(user)
      end

      private

      def token
        token_from_headers || token_from_params
      end

      def token_from_headers
        authorization_header = env["HTTP_AUTHORIZATION"]
        return unless authorization_header
        type, token = authorization_header.split
        type =~ /Bearer/i ? token : nil
      end

      def token_from_params
        params.dig Devise::Fireauth.token_key
      end
    end
  end
end

Warden::Strategies.add(:firebase_jwt, Warden::Fireauth::Strategy)
