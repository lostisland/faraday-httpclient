# Faraday HTTPClient adapter

This gem is a [Faraday][faraday] adapter for the [HTTPClient][httpclient] library.
Faraday is an HTTP client library that provides a common interface over many adapters.
Every adapter is defined into its own gem. This gem defines the adapter for HTTPClient.

> **Note**: Faraday 2.11.0 introduces a new SSL option: `ciphers`, allowing you to specify the SSL/TLS cipher suites. This adapter supports this option when using Faraday 2.11.0 or later.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'faraday-httpclient', '~> 2.0'
```

And then execute:

    $ bundle install

Or install them yourself as:

    $ gem install faraday-httpclient -v '~> 2.0'

## Usage

```ruby
require 'faraday/httpclient'

# Basic configuration
conn = Faraday.new(...) do |f|
  f.adapter :httpclient do |client|
    # yields HTTPClient
    client.keep_alive_timeout = 20
    client.ssl_config.timeout = 25
  end
end

# With SSL configuration (including ciphers)
conn = Faraday.new(
  url: 'https://example.com',
  ssl: {
    verify: true,                    # enable/disable SSL verification
    ca_file: '/path/to/ca.pem',     # custom CA file
    client_cert: client_cert,        # client certificate
    client_key: client_key,         # client private key
    verify_depth: 5,                # verification depth
    ciphers: ['TLS_AES_256_GCM_SHA384']  # supported in Faraday 2.11.0+
  }
) do |f|
  f.adapter :httpclient
end
```

## SSL Configuration

The adapter supports various SSL configuration options through Faraday's SSL options hash:

### Standard SSL Options (All Versions)

- `verify`: Enable/disable SSL verification (default: `true`)
- `ca_file`: Path to CA certificate file
- `ca_path`: Path to CA certificate directory
- `cert_store`: Custom certificate store (instance of `OpenSSL::X509::Store`)
- `client_cert`: Client certificate for authentication
- `client_key`: Client private key for authentication
- `verify_depth`: Maximum depth for certificate chain verification

### Faraday 2.11.0+ SSL Options

- `ciphers`: Array of cipher suite names to configure allowed SSL/TLS cipher suites

When using SSL verification (the default), the adapter will use system CA certificates. You can customize this by providing a `ca_file`, `ca_path`, or `cert_store`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](rubygems).

## Contributing

Bug reports and pull requests are welcome on [GitHub][repo].

## License

The gem is available as open source under the terms of the [license][license].

## Code of Conduct

Everyone interacting in the Faraday HTTPClient adapter project's codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct][code-of-conduct].

[faraday]: https://github.com/lostisland/faraday
[httpclient]: https://github.com/nahi/httpclient
[rubygems]: https://rubygems.org
[repo]: https://github.com/lostisland/faraday-httpclient
[license]: https://github.com/lostisland/faraday-httpclient/blob/main/LICENSE.md
[code-of-conduct]: https://github.com/lostisland/faraday-httpclient/blob/main/CODE_OF_CONDUCT.md
