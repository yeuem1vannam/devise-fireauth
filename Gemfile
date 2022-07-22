# frozen_string_literal: true
source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem "bootsnap", ">= 1.4.4", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "fakeweb"
  gem "pry-rails"
  gem "puma", "~> 5.0"
  gem "rails", "~> 6.1.4"
  gem "rspec-rails"
  gem "solargraph", require: false
  gem "sqlite3", "~> 1.4"
end

group :development do
  gem "guard-bundler"
  gem "guard-rails"
  gem "guard-rspec"
  gem "listen", "~> 3.3"
  gem "rails-erd", require: false
  gem "rubocop", "<= 1.6.1", require: false
  gem "rubocop-github", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "database_cleaner-active_record"
  gem "shoulda-matchers", "~> 5.0"
  gem "simplecov", require: false
  gem "timecop"
end

group :doc do
  gem "yard"
end
