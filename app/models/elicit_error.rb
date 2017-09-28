class ElicitError < StandardError
  attr_accessor :code, :message
  def initialize(message, code=500)
    self.code = code
    self.error_message = message
    super(message)
  end

  include Swagger::Blocks

  swagger_schema :ElicitError do
    key :required, [:code, :message]
    property :code do
      key :type, :integer
      key :format, :int64
    end
    property :message do
      key :type, :string
    end
  end

end
