# app/workers/event_consumer_worker.rb
# frozen_string_literal: true

class EventConsumerJob
  include Sidekiq::Job
  sidekiq_options retry: 3, dead: true

  def perform(payload)
    RabbitMQ.with_channel do |channel|
      event = parse_event(payload)
      log_event(event)

      # Add your business logic here
      # Example: EventLog.create!(event_type: event["type"], payload: event["data"])
    end
  rescue JSON::ParserError => e
    log_error("Invalid JSON payload", e, payload: payload)
    raise
  rescue => e
    log_error("Event processing failed", e, payload: payload)
    raise
  end

  private

  def parse_event(payload)
    JSON.parse(payload).tap do |event|
      raise ArgumentError, "Missing event type" unless event["type"]
      raise ArgumentError, "Missing event data" unless event["data"]
    end
  end

  def log_event(event)
    Rails.logger.info(
      message: "Processing event",
      event_type: event["type"],
      event_data: event["data"]
    )
  end

  def log_error(message, error, context = {})
    Rails.logger.error(
      message: message,
      error: error.message,
      backtrace: error.backtrace.take(5),
      **context
    )
  end
end
