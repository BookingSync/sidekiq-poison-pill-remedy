# frozen_string_literal: true

require "spec_helper"

RSpec.describe SidekiqPoisonPillRemedy do
  describe ".remedy" do
    subject(:call) { described_class.remedy.call(nil, job) }

    let(:default_queue) { "default" }
    let(:poison_pill_queue) { "poison_pill" }
    let(:enqueue_job) { MyJob.set(queue: job_queue).perform_async("fail") }
    let(:job) { Sidekiq::Queue.new(default_queue).find_job(enqueue_job) }

    before do
      Sidekiq::Testing.disable!
      Sidekiq::Queue.new(poison_pill_queue).clear
      Sidekiq::Queue.new(default_queue).clear

      enqueue_job

      # there is no easy way to move the job to DeadSet, the process is rather complex
      # we would ideally execute a single method call have a proper setup but in that case
      # we need to use stub
      allow_any_instance_of(Sidekiq::DeadSet).to receive(:find_job).with(enqueue_job).and_return(job)
    end

    context "when the job is a poison pill in non-poison pill queue" do
      let(:job_queue) { default_queue }

      it "moves job to poison_pill queue and sends error notification" do
        expect do
          call
        end.to change { Sidekiq::Queue.new(default_queue).count }.from(1).to(0)
          .and change { Sidekiq::Queue.new(poison_pill_queue).count }.from(0).to(1)
      end
    end

    context "when the job is a poison pill in poison pill queue" do
      let(:job_queue) { poison_pill_queue }

      it "keep the jobs in posion pill queue and sends error notification" do
        expect do
          call
        end.to avoid_changing { Sidekiq::Queue.new(default_queue).count }.from(0)
          .and avoid_changing { Sidekiq::Queue.new(poison_pill_queue).count }.from(1)
      end
    end
  end
end
