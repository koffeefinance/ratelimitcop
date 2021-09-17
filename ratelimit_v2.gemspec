require_relative 'lib/ratelimit_v2/version'

Gem::Specification.new do |spec|
  spec.name          = 'ratelimit_v2'
  spec.version       = RatelimitV2::VERSION
  spec.authors       = ['Mathusan Selvarajah']
  spec.email         = ['mathusans52@gmail.com']

  spec.summary       = 'A redis backed rate limiter.'
  spec.description   = 'A redis backed rate limiter. Appropriate for use cases where in-memory rate limiting \
                          would not work (i.e rate limiting across multiple processes, servers, apps, etc).'
  spec.homepage      = 'https://github.com/koffeefinance/ratelimit_v2'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/koffeefinance/ratelimit_v2'
  spec.metadata['changelog_uri'] = 'https://github.com/koffeefinance/ratelimit_v2/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency             'redis', '~> 4.4'
  spec.add_dependency             'redis-namespace', '~> 1.8.1'

  spec.add_development_dependency 'fakeredis', '~> 0.8.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'timecop', '~> 0.9.4'
end
