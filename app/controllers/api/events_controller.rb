class Api::EventsController < ApplicationController
  def create
    event = { type: params[:type], data: params[:data], timestamp: Time.now }

    # Publish to RabbitMQ
    channel = RABBITMQ_CONN.create_channel
    channel.default_exchange.publish(
      event.to_json,
      routing_key: "events.logger"
    )

    render json: { status: "Event queued!" }, status: :accepted
  end
end
