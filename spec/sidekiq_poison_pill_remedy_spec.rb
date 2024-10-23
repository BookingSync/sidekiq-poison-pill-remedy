# frozen_string_literal: true

require 'sidekiq/testing'
require 'rspec-sidekiq'
require 'sidekiq'
require 'sidekiq-poison-pill-remedy'
require 'support/my_job'
require 'sidekiq/api'

RSpec.describe SidekiqPoisonPillRemedy do
  before do
    Sidekiq::Testing.fake!
  end
  it 'moves job to poison_pill queue and logs message' do
    puts '1'
    jid = MyJob.perform_async('fail')
    puts "Jobs in Queue: #{Sidekiq::Queue.new.size}"
    puts "DeadSet size: #{Sidekiq::DeadSet.new.size}"
    puts '2'

    MyJob.drain
    puts '3'

    job = Sidekiq::DeadSet.new.find_job(jid)
    puts '4'
    puts "Job JID: #{jid}"
    puts "DeadSet size: #{Sidekiq::DeadSet.new.size}"

    expect(job).not_to be_nil
    expect(job.klass).to eq('MyJob')

    SidekiqPoisonPillRemedy.remedy.call(nil, job)

    puts "DeadSet jobs: #{Sidekiq::DeadSet.new.size}"
    puts "Queue jobs: #{Sidekiq::Queue.new.size}"
    puts "Job JID: #{jid}"

    poison_pill_job = Sidekiq::Queue.new('poison_pill').find_job(job.jid)
    expect(poison_pill_job).not_to be_nil
    puts "Poison Pill Job JID: #{poison_pill_job.jid}"
  end
end
