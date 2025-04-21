
# require "bunny"

# RABBITMQ_CONN = Bunny.new(
#   host: "localhost",
#   port: 5672,
#   user: "guest",
#   password: "guest"
# ).start

# # Define exchanges/queues
# channel = RABBITMQ_CONN.create_channel
# EXCHANGE = channel.fanout("events.fanout")  # Broadcast to all queues
# QUEUE = channel.queue("events.logger")      # Specific queue for logging

# # Bind queue to exchange
# QUEUE.bind(EXCHANGE)


# QUEUE.subscribe do |delivery_info, properties, payload|
#   EventLoggerJob.perform_async(payload)
# end
