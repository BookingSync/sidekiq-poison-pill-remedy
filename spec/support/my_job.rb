class MyJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(arg)
    if arg == 'fail'
      Sidekiq.logger.error('Forced failure for testing')

    else
      'surprise'
    end
  end
end
