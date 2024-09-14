# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

gem 'faraday', '>= 1.0'
gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.0'
gem 'simplecov', '~> 0.22.0'

gem 'webmock', '~> 3.4'

less_than_ruby_v27 = Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7.0')
gem 'rubocop', less_than_ruby_v27 ? '~> 1.12.0' : '~> 1.66.0'
gem 'rubocop-packaging', '~> 0.5'
gem 'rubocop-performance', '~> 1.20'
