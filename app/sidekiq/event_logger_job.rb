# app/sidekiq/event_logger_job.rb
class EventLoggerJob
  include Sidekiq::Job

  def perform(event_json)
    event = JSON.parse(event_json)
    puts "[LOG] #{event['type']}: #{event['data']}"
  end
end
