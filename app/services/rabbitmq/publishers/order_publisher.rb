class OrderPublisher
  def self.publish(event_type, data)
    channel = RabbitMQ.channel
    exchange = channel.default_exchange
    # temporal queue, to receive response
    queue = channel.queue("", exclusive: true)

    correlation_id = SecureRandom.uuid

    exchange.publish(
      data.to_json,
      routing_key: event_type,
      reply_to: queue.name,
      correlation_id: correlation_id
    )

    response = nil
    queue.subscribe(block: true) do |_, properties, body|
      if properties.correlation_id == correlation_id
        response = JSON.parse(body, symbolize_names: true)
        break
      end
    end

    response || { success: false, message: "No response received" }
  end
end
