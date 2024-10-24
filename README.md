# SidekiqPoisonPillRemedy

The Sidekiq Poison Pill Remedy gem enhances Sidekiq's job processing by automatically handling and rescheduling failed jobs (poison pills) with integrated logging and error tracking through Sentry, ultimately improving reliability and performance optimization.

## Installation

Add this line to your application's Gemfile:

`gem 'sidekiq-poison-pill-remedy'`

And then execute:

`$ bundle install`

Or install it yourself as:

`$ gem install sidekiq-poison-pill-remedy`

## Usage

The gem is supposed to be used in the following way when added to the application

Check Sidekiq super_fetch:[here](https://github.com/sidekiq/sidekiq/wiki/Reliability#using-super_fetch)

Remedy is supposed to be use like:
`config.super_fetch!(&SidekiqPoisonPillRemedy.remedy)`

When a job fails, the SidekiqPoisonPillRemedy captures the failure and determines whether the job should be moved to a dedicated poison_pill queue.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BookingSync/sidekiq-poison-pill-remedy.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
