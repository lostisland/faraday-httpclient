# frozen_string_literal: true

RSpec.describe Faraday::HTTPClient do
  it 'has a version number' do
    expect(Faraday::HTTPClient::VERSION).to be_a(String)
  end
end
