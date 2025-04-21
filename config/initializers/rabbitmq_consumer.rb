# config/initializers/rabbitmq_consumer.rb
require_relative "../../lib/rabbitmq"

Thread.new do
  begin
    queue = RabbitMQ.channel.queue("user_events_queue")
    queue.subscribe(block: true) do |delivery_info, properties, payload|
      event = JSON.parse(payload)
      puts "[CONSUMER] Processing: #{event['type']}"
      EventConsumerJob.perform_async(payload)
      # Example: Save to DB or trigger Sidekiq
      # EventLog.create!(event_type: event["type"], payload: event["data"])
    end
  rescue => e
    Rails.logger.error "RabbitMQ Consumer Error: #{e.message}"
    retry
  end
end
