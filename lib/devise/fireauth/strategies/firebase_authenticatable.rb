# frozen_string_literal: true

module Devise
  module Strategies
    class FirebaseAuthenticatable < Authenticatable
      def valid?
        !token.nil?
      end

      # Don't use Session
      def store?
        false
      end
      #
      # For an example check : https://github.com/plataformatec/devise/blob/master/lib/devise/strategies/database_authenticatable.rb
      #
      # Method called by warden to authenticate a resource.
      #
      def authenticate!
        #
        # mapping.to is a wrapper over the resource model
        #
        # Treat the password as idToken
        resource = mapping.to.firebase_authentication(token)

        return fail! unless resource

        # remote_authentication method is defined in Devise::Models::RemoteAuthenticatable
        #
        # validate is a method defined in Devise::Strategies::Authenticatable. It takes
        #a block which must return a boolean value.
        #
        # If the block returns true the resource will be loged in
        # If the block returns false the authentication will fail!
        #
        if validate(resource)
          success!(resource)
        end
      end

      def authenticate
        resource = mapping.to.firebase_authentication(token)
        # If authenticated, stop immediately - or continue
        resource ? success!(resource) : fail(resource)
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
