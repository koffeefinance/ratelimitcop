require 'ratelimitcop/version'
require 'redis'
require 'redis-namespace'
require_relative 'errors'

class Ratelimitcop
  attr_reader :name, :threshold, :interval

  def initialize(name:, threshold:, interval:, redis: {}, options: {})
    @name = name
    @threshold = threshold
    @interval = interval
    @bucket_interval = options[:bucket_interval] ||= 5
    @bucket_time_span = options[:bucket_time_span] ||= 600
    @bucket_span = options[:bucket_span] ||= @bucket_interval

    raise InvalidBucketConfigError if @bucket_interval > @bucket_time_span || @bucket_interval < @bucket_span

    @redis ||= Redis::Namespace.new(:limiter, redis: Redis.new(redis))

    @all_buckets_count = (@bucket_time_span / @bucket_span).floor
    @sliding_window_buckets_count = (@bucket_interval.to_f / @bucket_span).floor
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

  def execute(&block)
    add
    exec_within_threshold do
      block.call
    end
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
