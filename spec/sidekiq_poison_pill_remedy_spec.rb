# frozen_string_literal: true

require "sidekiq"
require "sidekiq/api"
require "sidekiq/testing"
require "rspec-sidekiq"
require "sidekiq-poison-pill-remedy"
require "support/my_job"

RSpec.describe SidekiqPoisonPillRemedy do
  before do
    Sidekiq::Testing.fake!
  end

  it "moves job to poison_pill queue and logs message" do
    puts "Starting test..."

    job_id = MyJob.perform_async(nil)


    expect(Sidekiq::Queue.new.size).to eq(1)
    expect(Sidekiq::Queue.new("poison_pill").size).to eq(0)
    puts "2"

    job = Sidekiq::Queue.new.find_job(job_id)

    SidekiqPoisonPillRemedy.remedy.call(nil, job)

    puts "Jobs in Queue: #{Sidekiq::Queue.new.size}"
    puts "3"

    expect(Sidekiq::Queue.new.size).to eq(0)
    expect(Sidekiq::Queue.new("poison_pill").size).to eq(1)
  end
end
