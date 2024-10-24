# frozen_string_literal: true

require "sidekiq"
require "sidekiq/api"
require "sidekiq/testing"
require "rspec-sidekiq"
require "sidekiq-poison-pill-remedy"
require_relative "jobs/my_job"
