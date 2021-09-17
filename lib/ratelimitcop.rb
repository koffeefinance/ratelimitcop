require 'ratelimitcop/version'
require 'redis'
require 'redis-namespace'

class Ratelimitcop
  attr_reader :name, :threshold, :interval, :time_span, :bucket_span

  def initialize(name:, threshold:, interval:, redis_connection: {}, time_span: 600, bucket_span: 5)
    @name = name
    @threshold = threshold
    @interval = interval
    @time_span = time_span
    @bucket_span = bucket_span

    raise ArgumentError if @interval > @time_span || @interval < @bucket_span

    @redis ||= Redis::Namespace.new(:limiter, redis: Redis.new(redis_connection))

    @all_buckets_count = (@time_span / @bucket_span).floor
    @sliding_window_buckets_count = (@interval.to_f / @bucket_span).floor
  end

  def add(count: 1)
    key = [@name, bucket_index].join(':')

    @redis.multi do
      @redis.incrby(key, count)
      @redis.expire(key, @interval)
    end

    nil
  end

  def count
    current_bucket_index = bucket_index

    bucket_indices = @sliding_window_buckets_count.times.map do |i|
      (current_bucket_index - i) % @all_buckets_count
    end

    @redis.multi do
      bucket_indices.map do |i|
        key = [@name, i].join(':')
        @redis.get(key)
      end
    end.map(&:to_i).sum
  end

  def exec_within_threshold
    sleep @bucket_span while exceeded?
    yield
  end

  def exceeded?
    count >= @threshold
  end

  private

  def bucket_index
    ((Time.now.to_i % @all_buckets_count) / @bucket_span).floor
  end
end
