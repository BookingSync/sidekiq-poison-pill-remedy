# frozen_string_literal: true

require "bundler/setup"
require "sidekiq/testing"
require "rspec-sidekiq"
require "sentry-ruby"
require "sidekiq"
require "sidekiq/api"
require "sidekiq-poison-pill-remedy"
require "support/my_job"

Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
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

  Sidekiq.configure_server do |sidekiq_config|
    sidekiq_config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
  end

  Sidekiq.configure_client do |sidekiq_config|
    sidekiq_config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
  end

  RSpec::Matchers.define_negated_matcher :avoid_changing, :change
end
