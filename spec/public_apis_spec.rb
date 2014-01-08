require_relative 'spec_helper'

describe BitBot::Btcchina do
  before :all do
    ENV['btcchina_key'] = 'KEY'
    ENV['btcchina_secret'] = 'SECRET'
  end

  after :all do
    ENV['btcchina_key'] = nil
    ENV['btcchina_secret'] = nil
  end

  describe "public APIs" do
    describe "#tickers" do
      subject { VCR.use_cassette('tickers') { BitBot[:btcchina].new.ticker } }

      it 'gets a ticker' do
        expect(subject.last).to eq(4778.01)
        expect(subject.converted.last).to eq(4778.01)
      end
    end

    describe "#offers" do
      subject { VCR.use_cassette('offers', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.offers } }

      it 'gets 10 bids and 10 asks' do
        expect(subject[:asks].size).to eq(10)
        expect(subject[:bids].size).to eq(10)
      end
    end

    describe "#bids" do
      subject { VCR.use_cassette('offers', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.bids } }

      it 'gets 10 bids' do
        expect(subject.size).to eq(10)
        expect(subject.first.price).to eq(4882.99)
        expect(subject.first.converted.price).to eq(4882.99)

        expect(subject.first.amount).to eq(52.428)
      end
    end

    describe "#asks" do
      subject { VCR.use_cassette('offers', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.asks } }

      it 'gets 10 bids' do
        expect(subject.size).to eq(10)
        expect(subject.first.price).to eq(4883.0)
        expect(subject.first.converted.price).to eq(4883.0)

        expect(subject.first.amount).to eq(43.088)
      end
    end
  end
end
