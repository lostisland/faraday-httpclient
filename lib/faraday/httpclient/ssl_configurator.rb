# frozen_string_literal: true

module Faraday
  module HTTPClient
    # Configures SSL options for HTTPClient
    class SSLConfigurator
      def self.configure(client, ssl)
        new(client, ssl).configure
      end

      def initialize(client, ssl)
        @client = client
        @ssl = ssl
      end

      def configure
        ssl_config = @client.ssl_config
        ssl_config.verify_mode = ssl_verify_mode
        ssl_config.cert_store = ssl_cert_store

        configure_ssl_options(ssl_config)
        configure_ciphers(ssl_config)
      end

      private

      attr_reader :ssl

      def configure_ssl_options(ssl_config)
        ssl_config.add_trust_ca ssl[:ca_file] if ssl[:ca_file]
        ssl_config.add_trust_ca ssl[:ca_path] if ssl[:ca_path]
        ssl_config.client_cert = ssl[:client_cert] if ssl[:client_cert]
        ssl_config.client_key = ssl[:client_key] if ssl[:client_key]
        ssl_config.verify_depth = ssl[:verify_depth] if ssl[:verify_depth]
      end

      def configure_ciphers(ssl_config)
        if Gem::Version.new(Faraday::VERSION) >= Gem::Version.new('2.11.0') &&
           ssl_config.respond_to?(:ciphers=)
          ssl_config.ciphers = ssl[:ciphers]
        end
      end

      # @param ssl [Hash]
      # @return [OpenSSL::X509::Store]
      def ssl_cert_store
        return ssl[:cert_store] if ssl[:cert_store]

        # Memoize the cert store so that the same one is passed to
        # HTTPClient each time, to avoid resyncing SSL sessions when
        # it's changed

        # Use the default cert store by default, i.e. system ca certs
        @ssl_cert_store ||= OpenSSL::X509::Store.new.tap(&:set_default_paths)
      end

      # @param ssl [Hash]
      def ssl_verify_mode
        ssl[:verify_mode] || begin
          if ssl.fetch(:verify, true)
            OpenSSL::SSL::VERIFY_PEER |
              OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
          else
            OpenSSL::SSL::VERIFY_NONE
          end
        end
      end
    end
  end
end
