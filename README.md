# Ratelimitcop

[![Gem Version](https://badge.fury.io/rb/ratelimitcop.svg)](https://badge.fury.io/rb/ratelimitcop) ![Build Status](https://github.com/koffeefinance/ratelimitcop/actions/workflows/ruby.yml/badge.svg)

Ratelimitcop is a Redis backed rate limiter. Appropriate for use cases where in-memory rate limiting would not work (i.e rate limiting across multiple processes, servers, apps, etc).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ratelimitcop'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ratelimitcop

## Usage

### Basic Usage

To rate limit calling a block of code, simply initialize `Ratelimitcop` with a `threshold` and `interval`, then pass the block of code into the `execute` method. `threshold` is the maximum number of requests that can be made within a timed `interval`, where `interval` is in seconds. `execute` will automatically block if the execution of your code block will exceed the given rate limit.

Note: You need let Ratelimitcop know how it can connect to your Redis instance (or else it will default to `localhost`, port 6379, as per the [Redis gem docs](https://www.rubydoc.info/gems/redis#getting-started)). To do this pass your Redis connection config as a parameter when intializing Ratelimitcop. View the [Redis gem docs](https://www.rubydoc.info/gems/redis#getting-started) to see the different ways you can connect Ratelimitcop to your Redis instance.

Here is an example of an API client that uses Ratelimitcop to ensure the API's rate limits are not exceeded.

```ruby
  require `iex-ruby-client`
  require `ratelimitcop`

  class IEXCloudAPIClient
    def initialize
      # rate limit 100 calls per second
      @limiter = Ratelimitcop.new(
        name: 'iex_cloud_api',
        threshold: 100,
        interval: 1,
        redis: {
          url: ENV['REDIS_URL']
        }
      )

      @client = IEX::Api::Client.new
    end

    def quote(ticker:)
      # regardless of how this method is called it will block if rate limit is exceeded before trying to run the code block
      @limiter.execute do
        res = @client.quote(URI.encode(ticker))
        res
      end
    end
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/koffeefinance/ratelimitcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/koffeefinance/ratelimitcop/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ratelimitcop project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koffeefinance/ratelimitcop/blob/master/CODE_OF_CONDUCT.md).
