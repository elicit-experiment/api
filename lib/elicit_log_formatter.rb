#! frozen_string_literal

class ElicitLogFormatter < ::Logger::Formatter
  # This method is invoked when a log event occurs
  def call(severity, timestamp, progname, msg)
    hash = message_to_hash(msg)
    "#{hash.merge({ severity: severity, '@timestamp' => timestamp }).to_json}\n"
  end

  def message_to_hash(msg)
    case msg
    when String
      { message: msg }
    when Hash
      msg
    when Array
      if msg.size == 1
        message_to_hash msg.first
      else
        { messages: msg.map { |sub_message| message_to_hash sub_message } }
      end
    else
      { error: "INVALID_LOG #{msg.class}" }
    end
  end
end
