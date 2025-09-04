class CartChannel < ApplicationCable::Channel
  def subscribed
    @cart_id = params[:cart_id]
    stream_from "cart_updates:#{@cart_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Handle incoming messages if needed
  end
end
