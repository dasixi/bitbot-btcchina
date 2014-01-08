require_relative 'spec_helper'

describe BitBot::Btcchina do
  describe "calls private APIs" do
    before :all do
      ENV['btcchina_key'] = 'btcchina_key'
      ENV['btcchina_secret'] = 'btcchina_secret'
    end

    after :all do
      ENV['btcchina_key'] = nil
      ENV['btcchina_secret'] = nil
    end

    describe "#buy" do
      it 'bought without enough money' do
        expect{ VCR.use_cassette('authorized/failure/buy', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.buy amount: 10000, price: 10 } }.to raise_error(BitBot::BalanceError)
      end
    end

    describe "#sell" do
      it 'sold without enough bitcoin' do
        expect{ VCR.use_cassette('authorized/failure/sell', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.sell amount: 10000, price: 12345 } }.to raise_error(BitBot::BalanceError)
      end
    end

    describe "#cancel and #sync" do
      it 'cancel and sync without an error order id' do
        expect{ VCR.use_cassette('authorized/failure/cancel', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.cancel 1 } }.to raise_error(BitBot::Error)
        expect{ VCR.use_cassette('authorized/failure/sync', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.sync 1 } }.to raise_error(BitBot::OrderNotFoundError)
      end
    end

    describe "#orders" do
      subject { VCR.use_cassette('authorized/empty/orders', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.orders } }

      it "account has no orders" do
        expect(subject.size).to eq(0)
      end
    end
  end
end
