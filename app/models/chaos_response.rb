
# class to encapsulate a response for the Chaos Portal client

class ChaosResponse

  attr_accessor :Body
  attr_accessor :Error
  attr_accessor :Header

  def initialize(results)
    @Body = {
      "Count": results.count,
      "Results": results,
      "TotalCount": results.count      
    }
    @Error = {
      "Fullname": nil,
      "InnerException": nil,
      "Message": nil
    }
    @Header = {
      "Duration": 69.2729
    }
  end
end