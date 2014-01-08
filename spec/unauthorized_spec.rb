require_relative 'spec_helper'

describe BitBot::Btcchina do
  describe "#initialized without key and secret" do
    subject { BitBot[:btcchina].new }

    it "doesn't send request and raises UnauthorizedError" do
      expect{ subject.orders }.to raise_error(BitBot::UnauthorizedError)
    end
  end

  describe "calls private APIs with incorrect key and secret" do
    before :all do
      ENV['btcchina_key'] = 'btcchina_key'
      ENV['btcchina_secret'] = 'btcchina_secret'
    end

    after :all do
      ENV['btcchina_key'] = nil
      ENV['btcchina_secret'] = nil
    end

    it "raises UnauthorizedError" do
      expect { VCR.use_cassette('unauthorized/buy', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.buy amount: 0.01, price: 833 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/sell', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.sell amount: 0.01, price: 799 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/cancel', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.cancel 1 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/sync', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.sync 1 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/orders', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.orders } }.to raise_error(BitBot::UnauthorizedError)
    end
  end
end
