# frozen_string_literal: true

class ElicitError < StandardError
  attr_accessor :code, :message, :details

  def initialize(message, code = 500, details = nil)
    self.code = code
    self.message = message
    self.details = details
    super(message)
  end

  def to_json(options = nil)
    x = { message: message,
          code: Rack::Utils::SYMBOL_TO_STATUS_CODE[code],
          details: details }
    ActiveSupport::JSON.encode(x, options)
  end

  include Swagger::Blocks

  swagger_schema :ElicitError do
    key :required, %i[code message]
    property :code do
      key :type, :integer
      key :format, :int64
    end
    property :message do
      key :type, :string
    end
    property :details do
      key :type, :object
    end
  end
end
