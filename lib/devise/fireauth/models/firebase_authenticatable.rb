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
        FIREBASE_USER_INFO_URL = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=#{Fireauth.api_key}"
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

        #
        # Here you do the request to the external webservice
        #
        # If the authentication is successful you should return
        # a resource instance
        #
        # If the authentication fails you should return false
        #
        def firebase_authentication(auth_params)
          auth_hash = firebase_verification(auth_params[Fireauth.token_key])
          return nil if auth_hash.empty?
          unless defined? self.from_firebase
            raise NotImplementedError,
              "#{self.name} model must implement class method `from_firebase'"
          end
          # Create new user here and return user
          self.from_firebase(auth_hash)
        end

        private

        # TODO:
        # Verify the correct token
        # https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients
        def firebase_verification(id_token)
          firebase_verification_call = HTTParty.post(
            FIREBASE_USER_INFO_URL,
            headers: {
              'Content-Type': 'application/json'
            },
            body: {
              'idToken': id_token
            }.to_json
          )
          if firebase_verification_call.response.code == "200"
            firebase_infos = firebase_verification_call.parsed_response
            firebase_infos["users"][0]
          else
            {}
          end
        end
      end
    end
  end
end
