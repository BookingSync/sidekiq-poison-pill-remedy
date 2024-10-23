class MyJob
  include Sidekiq::Worker

  def perform(arg)
    raise 'An error occurred!' if arg == 'fail'
  end
end
