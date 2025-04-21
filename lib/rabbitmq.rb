require "bunny"

module RabbitMQ
  class ConnectionError < StandardError; end

  CONFIG = {
    host: ENV["RABBITMQ_HOST"] || "localhost",
    port: ENV["RABBITMQ_PORT"] || 5672,
    user: ENV["RABBITMQ_USER"] || "guest",
    password: ENV["RABBITMQ_PASSWORD"] || "guest",
    vhost: ENV["RABBITMQ_VHOST"] || "/",
    heartbeat: ENV["RABBITMQ_HEARTBEAT"] || 30
  }.freeze

  def self.connection
    @connection ||= begin
      conn = Bunny.new(CONFIG)
      conn.start
    rescue Bunny::TCPConnectionFailed, Bunny::PossibleAuthenticationFailureError => e
      raise ConnectionError, "Failed to connect to RabbitMQ: #{e.message}"
    end
  end

  def self.channel
    @channel ||= begin
      connection.create_channel.tap do |ch|
        ch.prefetch(1) # Limit unacknowledged messages
        ch.confirm_select # Enable publisher confirms
      end
    rescue Bunny::ChannelAlreadyClosed => e
      reset_connection!
      retry
    end
  end

  def self.with_channel
    retries ||= 0
    yield channel
  rescue Bunny::Exception => e
    if (retries += 1) <= 3
      reset_connection!
      retry
    else
      raise ConnectionError, "RabbitMQ operation failed after #{retries} attempts: #{e.message}"
    end
  end

  def self.reset_connection!
    @channel&.close
    @connection&.close
  ensure
    @channel = nil
    @connection = nil
  end
end
