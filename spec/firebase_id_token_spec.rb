require "spec_helper"
require "fakeweb"
require "openssl"
require "jwt"

CERTS_URI = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

RSpec.describe FirebaseIDToken::Validator do

  describe "#check" do
    before(:all) do
      crypto = generate_certificate
      @key = crypto[:key]
      @cert = crypto[:cert]
    end

    let(:project_id) { "my-firebase-project-id" }
    let(:aud) { project_id }
    let(:iss) { "https://securetoken.google.com/#{project_id}" }
    let(:exp) { Time.now + 10 }

    let(:payload) { {
      exp: exp.to_i,
      iss: iss,
      aud: aud,
      user_id: "12345",
      email: "test@gmail.com",
      provider_id: "google.com",
      verified: true
    }}

    let(:token) { JWT.encode(payload, @key, "RS256") }

    context "with old_skool certs" do
      let(:validator) { FirebaseIDToken::Validator.new aud: project_id }

      context "when unable to fetch Google certs" do
        before do
          FakeWeb::register_uri :get, CERTS_URI,
            status: ["404", "Not found"], body: "Ouch!"
        end

        it "raises an error" do
          expect {
            validator.check("whatever")
          }.to raise_error(FirebaseIDToken::CertificateError)
        end
      end

      context "when able to fetch old_skool certs" do
        before(:all) do
          crypto = generate_certificate
          @key2 = crypto[:key]
          @cert2 = crypto[:cert]
          @certs_body = JSON.dump({
           "123" => @cert.to_pem,
           "321" => @cert2.to_pem
          })
        end

        before do
          FakeWeb::register_uri :get, CERTS_URI,
            status: ["200", "Success"], body: @certs_body
        end

        it "successfully validates a good token" do
          result = validator.check(token)
          expect(result).to_not be_nil
          expect(result["aud"]).to eq aud
        end

        it "fails to validate a mangled token" do
          bad_token = token.gsub("x", "y")
          expect {
            validator.check(bad_token)
          }.to raise_error(FirebaseIDToken::SignatureError)
        end

        it "fails to validate a good token with wrong aud field" do
          validator = FirebaseIDToken::Validator.new(aud: "other-project-id")
          expect {
            validator.check(token)
          }.to raise_error(FirebaseIDToken::AudienceMismatchError)
        end

        context "when token is expired" do
          let(:exp) { Time.now - 10 }

          it "fails to validate a good token" do
            expect {
              validator.check(token)
            }.to raise_error(FirebaseIDToken::ExpiredTokenError)
          end
        end

        context "with an invalid issuer" do
          let(:iss) { "https://accounts.fake.com" }

          it "fails to validate a good token" do
            expect {
              validator.check(token)
            }.to raise_error(FirebaseIDToken::InvalidIssuerError)
          end
        end

        context "when certificates are not expired" do
          before { validator.instance_variable_set(:@certs_last_refresh, Time.now) }

          it "fails to validate a good token" do
            expect {
              validator.check(token)
            }.to raise_error(FirebaseIDToken::SignatureError)
          end
        end

        context "when certificates are expired" do
          let(:validator) { FirebaseIDToken::Validator.new(aud: project_id, expiry: 60) }
          before { validator.instance_variable_set(:@certs_last_refresh, Time.now - 120) }

          it "fails to validate a good token" do
            result = validator.check(token)
            expect(result).to_not be_nil
            expect(result["aud"]).to eq aud
          end
        end
      end
    end
  end

  def generate_certificate
    key = OpenSSL::PKey::RSA.new(2048)
    public_key = key.public_key

    cert_subject = "/C=BE/O=Test/OU=Test/CN=Test"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(cert_subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0x0
    cert.version = 2

    cert.sign key, OpenSSL::Digest::SHA1.new

    { key: key, cert: cert }
  end
end
