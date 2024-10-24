# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sidekiq-poison-pill-remedy.gemspec
gemspec

gem "rake", "~> 13.0"
gem "sentry-ruby"

group :development, :test do
  gem "rspec", "~> 3.0"
  gem "rspec-sidekiq"
  gem "rubocop", "~> 1.40", require: false
  gem "rubocop-performance"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end
