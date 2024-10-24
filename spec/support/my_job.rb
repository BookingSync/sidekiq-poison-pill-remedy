# frozen_string_literal: true

class MyJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  def perform(arg)
    raise StandardError, "Forced failure for testing" if arg == "fail"
  end
end
