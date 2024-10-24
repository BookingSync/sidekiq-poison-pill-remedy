# frozen_string_literal: true

require "sidekiq"

class MyJob
  include Sidekiq::Job
  sidekiq_options retry: 1

  def perform(arg)
    raise StandardError, "Forced failure for testing" if arg == "fail"
  end
end
