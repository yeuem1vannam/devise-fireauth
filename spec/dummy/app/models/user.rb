class User < ApplicationRecord
  devise :firebase_authenticatable, :rememberable

  class << self
    # {
    #   "localId": "XXxxxx",
    #   "email": "user@gmail.com",
    #   "displayName": "Phuong Le",
    #   "photoUrl": "https://lh3.googleusercontent.com/-/photo.jpg",
    #   "emailVerified": true,
    #   "providerUserInfo":  [{
    #     "providerId": "google.com",
    #     "displayName": "Phuong Le",
    #     "photoUrl": "https://lh3.googleusercontent.com/-/photo.jpg",
    #     "federatedId": "YYYyyy",
    #     "email": "user@gmail.com",
    #     "rawId": "Zzzzzz"
    #   }]
    # }
    def from_firebase(auth_hash)
      user = User.find_or_create_by(email: auth_hash["email"]) do |u|
        u.name = auth_hash["displayName"]
      end
      user
    end
  end
end
