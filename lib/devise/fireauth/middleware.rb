# frozen_string_literal: true
require_relative "middleware/firebase_jwt"

module Devise
  module Fireauth
    class Middleware
      attr_reader :app

      def initialize(app)
        @app = app
      end

      def call(env)
        builder = Rack::Builder.new
        builder.use FirebaseJWT
        builder.run(app)
        builder.call(env)
      end
    end
  end
end
