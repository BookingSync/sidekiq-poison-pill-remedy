# frozen_string_literal: true

require "sidekiq"
require "sidekiq/api"
require "sidekiq/testing"
require "rspec-sidekiq"
require "sidekiq-poison-pill-remedy"
require_relative "jobs/my_job"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end
