# a dummy API to help test ratelimitcop
class DummyAPI
  # default rate limit set to 10 reqs/second
  def initialize(rate_limit_threshold: 10, rate_limit_interval: 1)
    @count = 0
    @threshold = rate_limit_threshold
    @interval = rate_limit_interval
  end

  def request
    @current_time = Time.now.to_i
    @start ||= @current_time
    @end ||= @start + @interval

    @count += 1

    raise TooManyRequestsError if @count > @threshold && @current_time < @end
    return unless @current_time > @end

    @start = @current_time
    @end = @start + @interval
    @count = 0
  end
end

class TooManyRequestsError < StandardError; end
