class CartEvents
  CHANNEL_PREFIX = "cart_updates"

  def self.publish(cart_id)
    Redis.current.publish("#{CHANNEL_PREFIX}:#{cart_id}", {
      cartId: cart_id,
      timestamp: Time.now.to_i
    }.to_json)
  rescue Redis::BaseError => e
    Rails.logger.error "Failed to publish cart event: #{e.message}"
  end

  def self.subscribe(cart_id, &block)
    Redis.current.subscribe("#{CHANNEL_PREFIX}:#{cart_id}") do |on|
      on.message do |channel, message|
        data = JSON.parse(message)
        block.call(data)
      end
    end
  rescue Redis::BaseError => e
    Rails.logger.error "Failed to subscribe to cart events: #{e.message}"
  end
end
