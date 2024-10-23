# frozen_string_literal: true

require 'sidekiq/testing'
require 'rspec-sidekiq'
require 'sidekiq'
require 'sidekiq-poison-pill-remedy'
require 'support/my_job'

RSpec.describe SidekiqPoisonPillRemedy do
  let(:job_args) { ['test_argument'] }
  let(:jid) { MyJob.perform_async(*job_args) }

  before do
    Sidekiq::Testing.fake!
  end

  it 'moves job to poison_pill queue and logs message' do
    begin
      MyJob.new.perform('fail')
    rescue StandardError
      nil
    end

    job = Sidekiq::DeadSet.new.find_job(jid)

    expect(job).not_to be_nil
    expect(job.klass).to eq('MyJob')

    SidekiqPoisonPillRemedy.remedy.call(nil, job)

    poison_pill_job = Sidekiq::Queue.new('poison_pill').find_job(job.jid)
    expect(poison_pill_job).not_to be_nil
  end
end
