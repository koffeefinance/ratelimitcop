require 'test_helper'

class DummyAPITest < Minitest::Test
  def setup
    @dummy_api = DummyAPI.new(
      rate_limit_threshold: 10,
      rate_limit_interval: 1
    )
  end

  def after
    Timecop.return
  end

  def test_dummy_api_actually_rate_limits
    assert_raises TooManyRequestsError do
      11.times { @dummy_api.request }
    end
  end

  def test_dummy_api_does_not_raise_error_if_request_called_according_to_limts
    request_count = 0
    10.times do
      @dummy_api.request
      request_count += 1
    end

    Timecop.travel(1)

    10.times do
      @dummy_api.request
      request_count += 1
    end

    assert_equal 20, request_count
  end
end
