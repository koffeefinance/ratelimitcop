require 'test_helper'
require 'redis'

class RatelimitV2Test < Minitest::Test
  def setup
    @limiter = RatelimitV2.new(
      name: 'test',
      threshold: 10,
      interval: 5,
      time_span: 600
    )

    # Will connect to the fakeredis that the limiter is connected to
    @redis = Redis.new
    @redis.flushdb
  end

  def test_that_it_has_a_version_number
    refute_nil ::RatelimitV2::VERSION
  end

  def test_argument_error_raised_if_interval_greater_than_time_span
    assert_raises ArgumentError do
      RatelimitV2.new(
        name: 'test',
        threshold: 10,
        interval: 800,
        time_span: 600
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

  # note: this is sort of an integration test rather than a unit test
  def test_exec_within_threshold_waits_when_threshold_hit
    limiter = RatelimitV2.new(
      name: 'test',
      threshold: 10,
      interval: 4,
      bucket_span: 4,
      time_span: 600
    )

    count = 0

    # verifies sleep is actually called
    assert_raises Timeout::Error do
      Timeout.timeout(3) do
        12.times do
          limiter.add
          limiter.exec_within_threshold do
            count += 1
          end
        end
      end
    end

    count = 0

    # fast forward 15 seconds where rate limits should be cleared
    Timecop.travel(15) do
      assert !limiter.exceeded?
      # since rate limit is 10 operations per 4 seconds, 12 operations should finish in 5 seconds
      Timeout.timeout(5) do
        12.times do
          limiter.add
          limiter.exec_within_threshold do
            count += 1
          end
        end
      end
    end

    assert_equal 12, count
  end

  def test_bucket_index_returns_expected_index
    stub_time

    assert_equal 22, @limiter.send(:bucket_index)
  end

  def stub_time
    test_time = 1_631_816_992
    Time.stubs(:now).returns(Time.at(test_time))
  end
end
