# frozen_string_literal: true
require "warden"

module Devise
  module Fireauth
    class Middleware
      class FirebaseJWT < Middleware
        def call(env)
          env["warden"].authenticate(:firebase_jwt)
          app.call(env)
        end
      end
    end
  end
end
