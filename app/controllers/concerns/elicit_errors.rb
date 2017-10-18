module ElicitErrors
    def not_found(message = "object not found")
      raise ElicitError.new(message, :not_found)
    end

    def unprocessable_entity(message = "object not found")
      raise ElicitError.new(message, :unprocessable_entity)
    end

    def permission_denied
      raise ElicitError.new("permission denied", :unauthorized)
    end
end
