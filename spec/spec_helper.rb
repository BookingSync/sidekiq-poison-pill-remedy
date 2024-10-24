# frozen_string_literal: true

require "bundler/setup"
require "sidekiq/testing"
require "rspec-sidekiq"
require "sentry-ruby"
require "sidekiq"
require "sidekiq-poison-pill-remedy"

Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  Sidekiq::Testing.inline!
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    ENV["REDIS_URL"] ||= "redis://localhost:6379/1"
  end
end
