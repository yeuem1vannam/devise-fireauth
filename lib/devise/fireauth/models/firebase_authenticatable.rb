# frozen_string_literal: true
require "active_support/concern"

module Devise
  module Models
    module FirebaseAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_accessor Fireauth.token_key
      end

      module ClassMethods
        ####################################
        # Overriden methods from Devise::Models::Authenticatable
        ####################################

        #
        # This method is called from:
        # Warden::SessionSerializer in devise
        #
        # It takes as many params as elements had the array
        # returned in serialize_into_session
        #
        # Recreates a resource from session data
        #
        def serialize_from_session(id)
          resource = self.new
          resource.id = id
          resource
        end

        #
        # Here you have to return and array with the data of your resource
        # that you want to serialize into the session
        #
        # You might want to include some authentication data
        #
        def serialize_into_session(record)
          [record.id]
        end

        def from_firebase(auth_hash)
          raise NotImplementedError,
            "#{self.name} model must implement class method `from_firebase'"
        end

        #
        # Here you do the request to the external webservice
        #
        # If the authentication is successful you should return
        # a resource instance
        #
        # If the authentication fails you should return false
        #
        def firebase_authentication(id_token)
          auth_hash = firebase_verification(id_token)
          return nil if auth_hash.empty?
          # Create new user here and return user
          self.from_firebase(auth_hash)
        end

        private

        def firebase_verification(id_token)
          Fireauth.firebase_validator.check id_token
        rescue => e
          puts e.message
          {}
        end
      end
    end
  end
end
