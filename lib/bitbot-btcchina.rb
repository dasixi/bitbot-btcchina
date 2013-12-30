require 'kublai'

module BitBot
  module Btcchina
    ### INFO ###
    def ticker
      client.ticker
    end

    def asks
      client.get_market_depth['ask']
    end

    def bids
      client.get_market_depth['bid']
    end

    ### TRADES ###

    def buy(options)
      amount = options[:amount]
      price = options[:price]
      client.buy price, amount
    end

    def sell(options)
      amount = options[:amount]
      price = options[:price]
      client.sell price, amount
    end

    def cancel(order_id)
      client.cancel order_id
    end

    ### ACCOUNT ###
    def orders
      client.get_orders
    end


    private
    def client
      @client ||= Kublai::BTCChina.new @key, @secret
    end
  end
end

BitBot.define :btcchina, BitBot::Btcchina
