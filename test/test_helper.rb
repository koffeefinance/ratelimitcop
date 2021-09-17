$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ratelimitcop'

require 'minitest/autorun'
require 'mocha/minitest'
require 'fakeredis/minitest'
require 'timecop'
