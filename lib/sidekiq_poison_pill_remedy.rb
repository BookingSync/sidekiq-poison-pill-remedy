# frozen_string_literal: true

module SidekiqPoisonPillRemedy
  def self.remedy
    proc do |_jobstr, pill|
      next unless pill

      job = Sidekiq::DeadSet.new.find_job(pill.jid)

      if job.queue == 'poison_pill'
        capture_sentry_message(
          "#{job.klass} failed in the `#{job.queue}`, this means that it has to be urgently optimized on memory usage",
          level: :critical,
          job_item: job.item
        )
      else
        capture_sentry_message(
          "#{job.klass} was marked as `poison pill`, please create the job memory optimizations ticket timely",
          level: :warning,
          job_item: job.item
        )
        job.klass.constantize.set(queue: :poison_pill).perform_async(*job.args)
        job.delete
      end
    end
  end

  def self.capture_sentry_message(message, level:, job_item:)
    if defined?(Sentry)
      Sentry.capture_message(
        message,
        level: level,
        extra: { job_item: job_item }
      )
    end

    Sidekiq.logger.fatal(message)
  end
end
