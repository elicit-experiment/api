# frozen_string_literal: true

require 'tempfile'
require 'timeout'

module StudyTransfers
  # The same installed Python package powers offline tools and server jobs.
  # Arguments are passed as argv, never through a shell. Files avoid pipe buffers
  # and keep large documents out of command lines and job arguments.
  class Compiler
    def self.run(*arguments)
      errors = Tempfile.new('study-compiler-errors')
      pid = Process.spawn(ENV.fetch('STUDY_FORMAT_PYTHON', 'python3'), '-m', 'elicit_study.delivery',
                          *arguments.map(&:to_s), out: File::NULL, err: errors.path)
      status = nil
      begin
        Timeout.timeout(15.minutes.to_i) { _, status = Process.wait2(pid) }
      rescue Timeout::Error
        begin
          Process.kill('KILL', pid)
        rescue Errno::ESRCH
          # The subprocess exited during timeout handling.
        end
        begin
          Process.wait(pid)
        rescue Errno::ECHILD
          # Already reaped.
        end
        raise 'Study processing exceeded its time limit'
      end
      return if status.success?

      diagnostic = begin
        JSON.parse(File.read(errors.path))
      rescue JSON::ParserError
        {}
      end
      raise InvalidDocument, diagnostic['issues'] if diagnostic['issues'].is_a?(Array)

      Rails.logger.error("Study compiler failed: #{File.read(errors.path)[0, 2000]}")
      raise 'Study compiler is unavailable or failed; check worker logs'
    ensure
      errors&.close!
    end
  end
end
