class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info 'Test job'
  end
end