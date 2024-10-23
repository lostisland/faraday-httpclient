# frozen_string_literal: true

require_relative 'lib/faraday/httpclient/version'

Gem::Specification.new do |spec|
  spec.name = 'faraday-httpclient'
  spec.version = Faraday::HTTPClient::VERSION
  spec.authors = ['@iMacTia']
  spec.email = ['giuffrida.mattia@gmail.com']

  spec.summary = 'Faraday adapter for HTTPClient'
  spec.description = 'Faraday adapter for HTTPClient'
  spec.homepage = 'https://github.com/lostisland/faraday-httpclient'
  spec.license = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = 'https://github.com/lostisland/faraday-httpclient'
  spec.metadata['changelog_uri'] = 'https://github.com/lostisland/faraday-httpclient'

  spec.files = Dir.glob('lib/**/*') + %w[README.md LICENSE.md]
  spec.require_paths = ['lib']

  spec.add_dependency 'httpclient', '>= 2.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
