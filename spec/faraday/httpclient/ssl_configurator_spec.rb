# frozen_string_literal: true

RSpec.describe Faraday::HTTPClient::SSLConfigurator do
  let(:client) { HTTPClient.new }
  let(:ssl) { {} }
  let(:configurator) { described_class.new(client, ssl) }

  describe '.configure' do
    it 'creates a new instance and configures it' do
      expect(described_class).to receive(:new).with(client, ssl).and_return(configurator)
      expect(configurator).to receive(:configure)
      described_class.configure(client, ssl)
    end
  end

  describe '#configure' do
    let(:ssl_config) { client.ssl_config }

    context 'with default settings' do
      before { configurator.configure }

      it 'sets verify mode to VERIFY_PEER with fail if no peer cert' do
        expected_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
        expect(ssl_config.verify_mode).to eq(expected_mode)
      end

      it 'sets a default cert store' do
        expect(ssl_config.cert_store).to be_a(OpenSSL::X509::Store)
      end
    end

    context 'with verify: false' do
      let(:ssl) { { verify: false } }

      it 'sets verify mode to VERIFY_NONE' do
        configurator.configure
        expect(ssl_config.verify_mode).to eq(OpenSSL::SSL::VERIFY_NONE)
      end
    end

    context 'with explicit verify_mode' do
      let(:ssl) { { verify_mode: OpenSSL::SSL::VERIFY_NONE } }

      it 'uses the provided verify mode' do
        configurator.configure
        expect(ssl_config.verify_mode).to eq(OpenSSL::SSL::VERIFY_NONE)
      end
    end

    context 'with custom cert store' do
      let(:cert_store) { OpenSSL::X509::Store.new }
      let(:ssl) { { cert_store: cert_store } }

      it 'uses the provided cert store' do
        configurator.configure
        expect(ssl_config.cert_store).to eq(cert_store)
      end
    end

    context 'with SSL options' do
      require 'tempfile'

      let(:client_cert) { OpenSSL::X509::Certificate.new }
      let(:client_key) { OpenSSL::PKey::RSA.new }
      let(:verify_depth) { 5 }
      let(:ca_file) do
        file = Tempfile.new(['ca', '.pem'])
        file.write('dummy CA content')
        file.close
        file.path
      end
      let(:ca_path) do
        Dir.mktmpdir('ca_certs')
      end
      let(:ssl) do
        {
          ca_file: ca_file,
          ca_path: ca_path,
          client_cert: client_cert,
          client_key: client_key,
          verify_depth: verify_depth
        }
      end

      before do
        allow(ssl_config).to receive(:add_trust_ca)
        configurator.configure
      end

      after do
        FileUtils.rm_f(ca_file)
        FileUtils.rm_rf(ca_path)
      end

      it 'configures all SSL options' do
        expect(ssl_config.cert_store).to be_a(OpenSSL::X509::Store)
        expect(ssl_config.client_cert).to eq(client_cert)
        expect(ssl_config.client_key).to eq(client_key)
        expect(ssl_config.verify_depth).to eq(verify_depth)
      end

      it 'adds trusted CA file and path' do
        expect(ssl_config).to have_received(:add_trust_ca).with(ca_file)
        expect(ssl_config).to have_received(:add_trust_ca).with(ca_path)
      end
    end

    context 'with cipher configuration' do
      let(:ciphers) { ['TLS_AES_256_GCM_SHA384'] }
      let(:ssl) { { ciphers: ciphers } }

      before do
        stub_const('Faraday::VERSION', '2.11.0')
        configurator.configure
      end

      it 'configures ciphers when supported' do
        expect(ssl_config).to respond_to(:ciphers=)
        expect(ssl_config.ciphers).to eq(ciphers)
      end

      context 'with older Faraday version' do
        before do
          stub_const('Faraday::VERSION', '2.10.0')
          allow(ssl_config).to receive(:respond_to?).with(:ciphers=).and_return(false)
          configurator.configure
        end

        it 'does not configure ciphers' do
          expect(ssl_config).not_to receive(:ciphers=)
        end
      end
    end
  end
end
