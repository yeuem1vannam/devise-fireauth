class User < ApplicationRecord
  devise :firebase_authenticatable, :rememberable

  class << self
    # {
    #   "iss": "https://securetoken.google.com/<project_id>",
    #   "name": "Phuong Le Hoai",
    #   "picture": "https://lh3.googleusercontent.com/~/photo.jpg",
    #   "aud": "<project_id>",
    #   "auth_time": 1537355743,
    #   "user_id": "<firebase_user_id>",
    #   "sub": "<firebase_user_id>",
    #   "iat": 1537355743,
    #   "exp": 1537359343,
    #   "email": "me@yeuem1vannam.com",
    #   "email_verified": true,
    #   "firebase": {
    #     "identities": {
    #       "google.com": [
    #         "<google_plus_id>"
    #       ],
    #       "email": [
    #         "me@yeuem1vannam.com"
    #       ]
    #     },
    #     "sign_in_provider": "google.com"
    #   }
    # }
    def from_firebase(auth_hash)
      user = User.find_or_create_by(email: auth_hash["email"]) do |u|
        u.name = auth_hash["name"]
      end
      user
    end
  end
end
