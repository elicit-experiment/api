
# class to encapsulate a response for the Chaos Portal client

class ChaosResponse

  attr_accessor :Body
  attr_accessor :Error
  attr_accessor :Header

  def initialize(results, error_msg = nil)
    @Body = {
      "Count": results != nil ? results.count : nil,
      "Results": results,
      "TotalCount": results != nil ? results.count : nil      
    }
    @Error = {
      "Exception": nil,
      "Fullname": nil,
      "InnerException": nil,
      "Message": error_msg,
      "Stacktrace": nil
    }
    @Header = {
      "Duration": 1.000
    }
  end
end