# frozen_string_literal: true

RSpec.describe Faraday::Adapter::HTTPClient do
  # ruby gem defaults for testing purposes
  let(:httpclient_open) { 60 }
  let(:httpclient_read) { 60 }
  let(:httpclient_write) { 120 }

  features :request_body_on_query_methods, :reason_phrase_parse, :compression,
           :trace_method, :local_socket_binding

  it_behaves_like 'an adapter'

  it 'allows to provide adapter specific configs' do
    adapter = described_class.new do |client|
      client.keep_alive_timeout = 20
      client.ssl_config.timeout = 25
    end

    client = adapter.build_connection(url: URI.parse('https://example.com'))
    expect(client.keep_alive_timeout).to eq(20)
    expect(client.ssl_config.timeout).to eq(25)
  end

  context 'SSL Configuration' do
    let(:adapter) { described_class.new }
    let(:ssl_options) { {} }
    let(:env) { { url: URI.parse('https://example.com'), ssl: ssl_options } }

    it 'configures SSL when URL scheme is https' do
      expect(Faraday::HTTPClient::SSLConfigurator).to receive(:configure)
      adapter.build_connection(env)
    end

    it 'skips SSL configuration when URL scheme is not https' do
      env[:url] = URI.parse('http://example.com')
      expect(Faraday::HTTPClient::SSLConfigurator).not_to receive(:configure)
      adapter.build_connection(env)
    end

    it 'skips SSL configuration when ssl options are not present' do
      env.delete(:ssl)
      expect(Faraday::HTTPClient::SSLConfigurator).not_to receive(:configure)
      adapter.build_connection(env)
    end

    it 'passes SSL options to configurator' do
      ssl_options.merge!(
        verify: true,
        ca_file: '/path/to/ca.pem',
        client_cert: 'cert',
        client_key: 'key',
        verify_depth: 5,
        ciphers: ['TLS_AES_256_GCM_SHA384']
      )

      expect(Faraday::HTTPClient::SSLConfigurator).to receive(:configure) do |client, ssl|
        expect(client).to be_a(HTTPClient)
        expect(ssl).to eq(ssl_options)
      end

      adapter.build_connection(env)
    end
  end

  context 'Options' do
    let(:request) { Faraday::RequestOptions.new }
    let(:env) { { request: request } }
    let(:options) { {} }
    let(:adapter) { Faraday::Adapter::HTTPClient.new }
    let(:client) { adapter.connection(url: URI.parse('https://example.com')) }

    it 'configures timeout' do
      assert_default_timeouts!

      request.timeout = 5
      adapter.configure_timeouts(client, request)

      expect(client.connect_timeout).to eq(5)
      expect(client.send_timeout).to eq(5)
      expect(client.receive_timeout).to eq(5)
    end

    it 'configures open timeout' do
      assert_default_timeouts!

      request.open_timeout = 1
      adapter.configure_timeouts(client, request)

      expect(client.connect_timeout).to eq(1)
      expect(client.send_timeout).to eq(httpclient_write)
      expect(client.receive_timeout).to eq(httpclient_read)
    end

    it 'configures multiple timeouts' do
      assert_default_timeouts!

      request.open_timeout = 1
      request.write_timeout = 10
      request.read_timeout = 5
      adapter.configure_timeouts(client, request)

      expect(client.connect_timeout).to eq(1)
      expect(client.send_timeout).to eq(10)
      expect(client.receive_timeout).to eq(5)
    end

    def assert_default_timeouts!
      expect(client.connect_timeout).to eq(httpclient_open)
      expect(client.send_timeout).to eq(httpclient_write)
      expect(client.receive_timeout).to eq(httpclient_read)
    end
  end
end
