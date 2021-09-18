require 'test_helper'
require 'redis'

class RatelimitcopTest < Minitest::Test
  def setup
    @limiter = Ratelimitcop.new(
      name: 'test',
      threshold: 10,
      interval: 5
    )

    # will connect to the fakeredis that the limiter is connected to
    @redis = Redis.new
    @redis.flushdb
  end

  def after
    Timecop.return
  end

  def test_that_it_has_a_version_number
    refute_nil ::Ratelimitcop::VERSION
  end

  def test_bucket_interval_option_is_set
    limiter = Ratelimitcop.new(
      name: 'test',
      threshold: 10,
      interval: 5,
      options: {
        bucket_interval: 6
      }
    )

    assert_equal 6, limiter.instance_variable_get(:@bucket_interval)
  end

  def test_bucket_time_span_option_is_set
    limiter = Ratelimitcop.new(
      name: 'test',
      threshold: 10,
      interval: 5,
      options: {
        bucket_time_span: 700
      }
    )

    assert_equal 700, limiter.instance_variable_get(:@bucket_time_span)
  end

  def test_bucket_span_option_is_set
    limiter = Ratelimitcop.new(
      name: 'test',
      threshold: 10,
      interval: 5,
      options: {
        bucket_span: 4
      }
    )

    assert_equal 4, limiter.instance_variable_get(:@bucket_span)
  end

  def test_invalid_bucket_config_error_raised_if_bucket_interval_greater_than_bucket_time_span
    assert_raises InvalidBucketConfigError do
      Ratelimitcop.new(
        name: 'test',
        threshold: 10,
        interval: 800,
        options: {
          bucket_interval: 800,
          bucket_time_span: 600
        }
      )
    end
  end

  def test_add_initializes_count_to_one
    stub_time

    @limiter.add
    assert_equal 1, @redis.get('limiter:test:22').to_i
  end

  def test_add_increments_count_by_one
    stub_time

    @limiter.add
    assert_equal 1, @redis.get('limiter:test:22').to_i

    @limiter.add
    assert_equal 2, @redis.get('limiter:test:22').to_i
  end

  def test_count_retuns_sum_across_all_buckets
    10.times { @limiter.add }

    assert_equal 10, @limiter.count
  end

  def test_exceed_returns_false_when_count_less_than_threshold
    9.times { @limiter.add }

    assert !@limiter.exceeded?
  end

  def test_exceed_returns_true_when_count_greater_than_threshold
    11.times { @limiter.add }

    assert @limiter.exceeded?
  end

  def test_exec_within_threshold_sleeps_when_threshold_is_hit
    limiter = Ratelimitcop.new(
      name: 'test',
      threshold: 10,
      interval: 4
    )

    count = 0

    # verifies sleep is actually called
    12.times { limiter.add }

    assert_raises Timeout::Error do
      Timeout.timeout(3) do
        limiter.exec_within_threshold do
          count += 1
        end
      end
    end
  end

  def test_bucket_index_returns_expected_index
    stub_time

    assert_equal 22, @limiter.send(:bucket_index)
  end

  def test_exec_handles_dummy_api_rate_limit
    limiter = Ratelimitcop.new(
      name: 'test_exec_handles_dummy_api_rate_limit',
      threshold: 10,
      interval: 2
    )

    dummy_api = DummyAPI.new(
      rate_limit_threshold: 10,
      rate_limit_interval: 2
    )

    count = 0

    15.times do
      limiter.execute do
        dummy_api.request
        count += 1
      end
    end

    assert_equal 15, count
  end

  def stub_time
    test_time = 1_631_816_992
    Time.stubs(:now).returns(Time.at(test_time))
  end
end
