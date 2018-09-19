# frozen_string_literal: true
# Original idea from https://github.com/google/google-id-token
require "json"
require "jwt"
require "monitor"
require "net/http"
require "openssl"

module FirebaseIDToken
  class CertificateError < StandardError; end
  class ValidationError < StandardError; end
  class ExpiredTokenError < ValidationError; end
  class SignatureError < ValidationError; end
  class InvalidIssuerError < ValidationError; end
  class AudienceMismatchError < ValidationError; end
  class ClientIDMismatchError < ValidationError; end

  # Verify the correct token
  # https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients
  class Validator
    include MonitorMixin

    GOOGLE_CERTS_URI = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
    GOOGLE_CERTS_EXPIRY = 3600 # 1 hour

    def initialize(aud:, expiry: GOOGLE_CERTS_EXPIRY)
      super()

      @aud = aud.to_s
      @iss = "https://securetoken.google.com/#{aud}"
      @certs_expiry = expiry
      @certs = {}
    end

    ##
    # If it validates, returns a hash with the JWT payload from the ID Token.
    #  You have to provide an "aud" value, which must match the
    #  token"s field with that name, and will similarly check cid if provided.
    #
    # If something fails, raises an error
    #
    # @param [String] token
    #   The string form of the token
    #
    # @return [Hash] The decoded ID token
    def check(token)
      synchronize do
        payload = check_cached_certs(token)

        unless payload
          # no certs worked, might've expired, refresh
          if refresh_certs
            payload = check_cached_certs(token)

            unless payload
              raise SignatureError, "Token not verified as issued by Google"
            end
          else
            raise CertificateError, "Unable to retrieve Google public keys"
          end
        end

        payload
      end
    end

    private

    # tries to validate the token against each cached cert.
    # Returns the token payload or raises a ValidationError or `nil',
    # which means none of the certs validated.
    def check_cached_certs(token)
      payload = nil

      # find first public key that validates this token
      @certs.detect do |key, cert|
        begin
          public_key = cert.public_key
          decoded_token = JWT.decode(token, public_key, !!public_key, { algorithm: "RS256" })
          payload = decoded_token.first

          payload
        rescue JWT::ExpiredSignature
          raise ExpiredTokenError, "Token signature is expired"
        rescue JWT::DecodeError
          nil # go on, try the next cert
        end
      end

      if payload
        if !(payload.has_key?("aud") && payload["aud"] == @aud)
          raise AudienceMismatchError, "Token audience mismatch"
        end
        if payload["iss"] != @iss
          raise InvalidIssuerError, "Token issuer mismatch"
        end
        payload
      else
        nil
      end
    end

    def refresh_certs
      return true unless certs_cache_expired?

      uri = URI(GOOGLE_CERTS_URI)
      get = Net::HTTP::Get.new uri.request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.request(get)

      if res.is_a?(Net::HTTPSuccess)
        new_certs = Hash[JSON.load(res.body).map do |key, cert|
          [key, OpenSSL::X509::Certificate.new(cert)]
        end]
        @certs.merge! new_certs
        @certs_last_refresh = Time.now
        true
      else
        false
      end
    end

    def certs_cache_expired?
      if defined? @certs_last_refresh
        Time.now > @certs_last_refresh + @certs_expiry
      else
        true
      end
    end
  end
end
