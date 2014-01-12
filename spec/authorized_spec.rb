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
      subject { VCR.use_cassette('authorized/success/buy', record: :new_episodes, match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.buy amount: 0.01, price: 4800 } }

      it 'bought 0.01 bitcoin at price CNY 4800' do
        expect(subject.order_id).to eq(9822030)
        expect(subject.side).to eq('buy')
        expect(subject.price).to eq(4800.0)
        expect(subject.avg_price).to eq(0.0)
        expect(subject.amount).to eq(0.01)
        expect(subject.remaining).to eq(0.01)
        expect(subject.status).to eq('open')
      end
    end

    describe "#sell" do
      subject { VCR.use_cassette('authorized/success/sell', record: :new_episodes, match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.sell amount: 0.01, price: 4400 } }

      it 'sold 0.01 bitcoin at price CNY 4400' do
        expect(subject.order_id).to be_nil
        expect(subject.side).to eq('sell')
        expect(subject.price).to eq(4400.0)
        expect(subject.avg_price).to eq(0.0)
        expect(subject.amount).to eq(0.01)
        expect(subject.remaining).to eq(0.0)
        expect(subject.status).to eq('closed')
      end
    end

    describe "#cancel and #sync" do
      subject { VCR.use_cassette('authorized/success/cancel', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.cancel 9822031 } }

      it 'cancelled an order' do
        expect(subject).to eq(true)
      end
    end

    describe "#sync" do
      subject { VCR.use_cassette('authorized/success/sync', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.sync 9822031 } }

      it 'updated an order status' do
        expect(subject.side).to eq('sell')
        expect(subject.price).to eq(12345.0)
        expect(subject.amount).to eq(0.01)
        expect(subject.remaining).to eq(0.01)
        expect(subject.status).to eq('cancelled')
      end
    end

    describe "#orders" do
      subject { VCR.use_cassette('authorized/success/orders', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.orders } }

      it 'fetched all account orders' do
        expect(subject.size).to eq(3)
        expect(subject.first.side).to eq('sell')
        expect(subject.first.price).to eq(12345)
      end
    end

    describe "#account" do
      subject { VCR.use_cassette('authorized/success/account', match_requests_on: [:method, body_matcher]){ BitBot[:btcchina].new.account } }

      it 'fetched account balances' do
        expect(subject.btc_balance.amount).to eq(2.13755)
        expect(subject.fiat_balance.amount).to eq(8851.29303)
      end
    end
  end
end
