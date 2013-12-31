require 'kublai'

module BitBot
  module Btcchina
    ### INFO ###
    def ticker
      map = {sell: :ask, buy: :bid}
      Ticker.new rekey(client.ticker, map)
    end

    def offers
      resp = client.get_market_depth
      asks = resp['ask'].collect do |offer|
        Offer.new offer
      end
      bids = resp['bid'].collect do |offer|
        Offer.new offer
      end
      {asks: asks, bids: bids}
    end

    def asks
      offers[:asks]
    end

    def bids
      offers[:bids]
    end

    ### TRADES ###
    def buy(options)
      amount = options[:amount]
      price = options[:price]
      client.buy price, amount
      orders.first
    end

    # true
    def sell(options)
      amount = options[:amount]
      price = options[:price]
      client.sell price, amount
      orders.first
    end

    def cancel(order_id)
      client.cancel order_id
    end

    ### ACCOUNT ###
    def orders
      resp = client.get_orders['order']
      resp.collect do |hash|
        build_order(hash)
      end
    end


    private
    def build_order(hash)
      map = {
        amount: :remaining,
        amount_original: :amount,
        date: :timestamp
      }
      Order.new rekey(hash, map)
    end

    def client
      @client ||= Kublai::BTCChina.new @key, @secret
    end
  end
end

BitBot.define :btcchina, BitBot::Btcchina
