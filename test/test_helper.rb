$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ratelimit_v2'

require 'minitest/autorun'
require 'mocha/minitest'
require 'fakeredis/minitest'
require 'timecop'
