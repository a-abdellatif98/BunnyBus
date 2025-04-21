# app/controllers/api/events_controller.rb
module Api
  class EventsController < ApplicationController
    before_action :validate_event_params

    # POST /api/events
    def create
      event = {
        type: params.require(:type),
        data: params.require(:data)
      }

      RabbitMQ.with_channel do |channel|
        channel.default_exchange.publish(
          event.to_json,
          routing_key: "user_events_queue",
          persistent: true
        )
      end

      render json: { status: "Event published!" }, status: :accepted
    rescue RabbitMQ::ConnectionError => e
      render json: { error: "Service unavailable" }, status: :service_unavailable
    rescue => e
      render json: { error: e.message }, status: :bad_request
    end

    private

    def validate_event_params
      params.require(:type)
      params.require(:data)
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
