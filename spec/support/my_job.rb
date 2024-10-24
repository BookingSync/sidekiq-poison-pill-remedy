# frozen_string_literal: true

class MyJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  def perform(arg)
    if arg.nil?
      raise StandardError, "Job was called with nil argument"
    else
      puts "Job executed successfully with argument: #{arg}"
    end
  end
end
