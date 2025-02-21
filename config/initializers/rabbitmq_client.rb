require 'bunny'

class RabbitMQClient
  def self.connection
    @connection ||= Bunny.new(
      hostname: ENV.fetch("RABBITMQ_HOST", "localhost"),
      port: ENV.fetch("RABBITMQ_PORT", 5672),
      username: ENV.fetch("RABBITMQ_USER", "guest"),
      password: ENV.fetch("RABBITMQ_PASSWORD", "guest"),
      automatic_recovery: true,
      heartbeat: 10
    )
    @connection.start unless @connection.connected?
    @connection
  end

  def self.channel
    unless @channel && @channel.alive?
      @channel ||= connection.create_channel
    end
    @channel
  end

  def self.close
    @channel&.close
    @connection&.close
    @channel = nil
    @connection = nil
  end
end
