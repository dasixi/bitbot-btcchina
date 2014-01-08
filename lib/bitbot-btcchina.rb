require 'kublai'

module BitBot
  module Btcchina
    ### INFO ###
    def ticker
      map = {sell: :ask, buy: :bid}
      resp = client.ticker
      check_response(resp)

      Ticker.new rekey(resp, map).merge(original: resp, agent: self)
    end

    def offers
      resp = client.get_market_depth
      check_response(resp)

      asks = resp['ask'].collect do |offer|
        Offer.new offer.merge(original: offer, agent: self)
      end

      bids = resp['bid'].collect do |offer|
        Offer.new offer.merge(original: offer, agent: self)
      end
      {asks: asks, bids: bids}
    end


    def asks
      offers[:asks]
    end

    def bids
      offers[:bids]
    end


    ### PRIVATE ###
    def buy(options)
      raise UnauthorizedError unless have_key?
      amount = options[:amount]
      price = options[:price]
      resp = client.buy price, amount
      check_response(resp)

      orders.first || Order.new(agent: self, side: 'buy', price: options[:price], amount: options[:amount], remaining: options[:amount], status: 'closed')
    end

    def sell(options)
      raise UnauthorizedError unless have_key?
      amount = options[:amount]
      price = options[:price]
      resp = client.sell price, amount
      check_response(resp)

      orders.first || Order.new(agent: self, side: 'sell', price: options[:price], amount: options[:amount], remaining: options[:amount], status: 'closed')
    end

    def cancel(order_id)
      raise UnauthorizedError unless have_key?
      resp = client.cancel order_id
      check_response(resp)

      resp
    end

    def sync(order_id)
      raise UnauthorizedError unless have_key?
      resp = client.get_order order_id
      check_response(resp)

      build_order(resp['order'])
    end

    ### ACCOUNT ###
    def orders
      raise UnauthorizedError unless have_key?
      resp = client.get_orders
      check_response(resp)

      resp['order'].collect do |hash|
        build_order(hash)
      end
    end

    def currency
      'CNY'
    end

    def rate
      1
    end

    private
    def check_response(response)
      return if response.is_a?(Array)
      return if response.is_a?(TrueClass)
      if error_msg = response['message']
        case error_msg
        when 'Unauthorized - invalid access key'
          raise UnauthorizedError, error_msg
        when 'Order not found'
          raise OrderNotFoundError, error_msg
        when 'Order already completed', 'Order already cancelled'
          raise Error, error_msg
        when 'Insufficient CNY balance', 'Insufficient BTC balance'
          raise BalanceError, error_msg
        else
          raise Error, error_msg
        end
      end
    end

    def build_order(hash)
      map = {
        amount: :remaining,
        amount_original: :amount,
        type: :side,
        date: :timestamp
      }
      Order.new rekey(hash, map).merge(original: hash, agent: self)
    end

    def have_key?
      @key && @secret
    end

    def client
      @client ||= Kublai::BTCChina.new @key, @secret
    end
  end
end

BitBot.define :btcchina, BitBot::Btcchina
