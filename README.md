# Devise Firebase authentication

A strategy to use Google Firebase as the authentication service behind the already famous authentication solution: [devise](https://github.com/plataformatec/devise)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "devise-fireauth"
```

And then execute:
```bash
$ bundle install
```

## Usage

- Get your Firebse's Web API Key, then add a configuration section into the devise's initializer
```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  # Other configuration
  config.authentication_keys = [
    # Other keys, ex: email
    :id_token
  ]
  config.strip_whitespace_keys = [
    # Other keys, ex: email
    :id_token
  ]
  config.fireauth do |f|
    f.api_key = "YoUR-weB-aPi-KEy"
    f.project_id = "firebase-project-id"
    f.token_key = :id_token
  end
end
```
- Modify your `User` model
  - Use `firebase_authenticatable` strategy for devise
  - Implement a class method `User.from_firebase` to find the corresponding user from your system. Example
```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :firebase_authenticatable
  class << self
    def from_firebase(auth_hash)
      # Find or create new user with auth_hash["email"]
      # Update user name with auth_hash["displayName"]
      # Return a user to allow login, or nil to reject
    end
  end
end
```

- Restart the server
- From now on, you can authenticate with the API via firebase `idToken` by one of:
  - Add params `id_token` to URL query
  - Attach the header `Authorization: Bearer #{id_token}` to the request

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yeuem1vannam/devise-fireauth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `devise-fireauth` project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yeuem1vannam/devise-fireauth/blob/master/CODE_OF_CONDUCT.md).
