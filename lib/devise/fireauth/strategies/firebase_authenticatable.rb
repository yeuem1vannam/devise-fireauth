# frozen_string_literal: true

module Devise
  module Strategies
    class FirebaseAuthenticatable < Authenticatable
      #
      # For an example check : https://github.com/plataformatec/devise/blob/master/lib/devise/strategies/database_authenticatable.rb
      #
      # Method called by warden to authenticate a resource.
      #
      def authenticate!
        #
        # authentication_hash doesn't include the password
        #
        auth_params = authentication_hash
        return fail! unless auth_params[Fireauth.token_key]

        #
        # mapping.to is a wrapper over the resource model
        #
        # Treat the password as idToken
        resource = mapping.to.firebase_authentication(auth_params)

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
    end
  end
end
