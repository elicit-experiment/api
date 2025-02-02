# frozen_string_literal: true

module ChaosApi
  module V6
    module TraceLogging
      extend ActiveSupport::Concern

      class_methods do
        def log_trace(*args)
          around_action :trace_action, only: args
        end
      end

      private

      def trace_action
        start_time = Time.current
        
        yield
        
        trace_data = {
          timestamp: start_time.iso8601,
          duration_ms: ((Time.current - start_time) * 1000).round(2),
          controller: self.class.name,
          action: action_name,
          session_guid: @session_guid,
          params: params.to_unsafe_h,
          response_status: response.status
        }

        write_trace(trace_data)
      end

      def write_trace(trace_data)
        trace_dir = Rails.root.join('tmp', 'traces', "#{self.class.name.underscore}##{action_name}")
        FileUtils.mkdir_p(trace_dir)
        
        trace_file = trace_dir.join("#{@session_guid}.ndjson")
        
        File.open(trace_file, 'a') do |f|
          f.puts(trace_data.to_json)
        end
      end
    end
  end
end
