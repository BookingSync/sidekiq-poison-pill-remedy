# frozen_string_literal: true

require "spec_helper"

RSpec.describe SidekiqPoisonPillRemedy do
  describe ".remedy" do
    subject(:call) { described_class.remedy.call(nil, job) }

    let(:default_queue) { "default" }
    let(:poison_pill_queue) { "poison_pill" }
    let(:enqueue_job) { MyJob.set(queue: job_queue).perform_async("fail") }
    let(:job) { Sidekiq::Queue.new(job_queue).find_job(enqueue_job) }

    before do
      Sidekiq::Testing.disable!
      Sidekiq::Queue.new(poison_pill_queue).clear
      Sidekiq::Queue.new(default_queue).clear

      enqueue_job

      allow_any_instance_of(Sidekiq::DeadSet).to receive(:find_job).with(enqueue_job).and_return(job)
      allow(Sentry).to receive(:capture_message).and_call_original
      allow(Sidekiq.logger).to receive(:fatal)
    end

    context "when the job is a poison pill in non-poison pill queue" do
      let(:job_queue) { default_queue }

      it "moves job to poison_pill queue and sends error notification" do
        expect do
          call
        end.to change { Sidekiq::Queue.new(default_queue).count }.from(1).to(0)
          .and change { Sidekiq::Queue.new(poison_pill_queue).count }.from(0).to(1)

        expect(Sentry).to have_received(:capture_message).with(
          "MyJob was marked as `poison pill`, please create the job memory optimizations ticket timely",
          level: :warning,
          extra: hash_including(:job_item)
        )
        expect(Sidekiq.logger).to have_received(:fatal).with(
          "MyJob was marked as `poison pill`, please create the job memory optimizations ticket timely"
        )
      end
    end

    context "when the job is a poison pill in poison pill queue" do
      let(:job_queue) { poison_pill_queue }

      it "keep the jobs in posion pill queue and sends error notification" do
        expect(job.queue).to eq("poison_pill")

        expect do
          call
        end.to avoid_changing { Sidekiq::Queue.new(default_queue).count }.from(0)
          .and avoid_changing { Sidekiq::Queue.new(poison_pill_queue).count }.from(1)

        expect(Sentry).to have_received(:capture_message).with(
          "MyJob failed in the `poison_pill`, this means that it has to be urgently optimized on memory usage",
          level: :critical,
          extra: hash_including(:job_item)
        )
        expect(Sidekiq.logger).to have_received(:fatal).with(
          "MyJob failed in the `poison_pill`, this means that it has to be urgently optimized on memory usage"
        )
      end
    end
  end
end
