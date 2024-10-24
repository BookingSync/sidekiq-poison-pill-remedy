# frozen_string_literal: true

require "sidekiq"
require "sidekiq/api"
require "sidekiq/testing"
require "rspec-sidekiq"
require "sidekiq-poison-pill-remedy"
require "support/my_job"

RSpec.describe SidekiqPoisonPillRemedy do
  before do
    Sidekiq::Testing.inline!
    allow(Sentry).to receive(:capture_message)
  end

  it "moves job to poison_pill queue and logs message" do
    puts "1"

    jid = nil
    expect do
      jid = MyJob.perform_async("fail")
    end.to raise_error(StandardError, "Forced failure for testing")

    puts "Jobs in Queue: #{Sidekiq::Queue.new.size}"
    puts "DeadSet size: #{Sidekiq::DeadSet.new.size}"

    puts "Jobs in DeadSet after processing: #{Sidekiq::DeadSet.new.size}"

    dead_set = Sidekiq::DeadSet.new
    expect(dead_set.size).to eq(1)
    job = dead_set.find_job(jid)

    puts "4"
    puts "Job JID: #{jid}"
    expect(job).not_to be_nil
    expect(job.klass).to eq("MyJob")

    expect { described_class.remedy.call(nil, job) }.not_to raise_error

    puts "DeadSet jobs: #{Sidekiq::DeadSet.new.size}"
    puts "Queue jobs: #{Sidekiq::Queue.new.size}"

    poison_pill_job = Sidekiq::Queue.new("poison_pill").find_job(job.jid)
    expect(poison_pill_job).not_to be_nil
    puts "Poison Pill Job JID: #{poison_pill_job.jid}"
  end
end
