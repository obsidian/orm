module ORM
  class ValidationErrors < Hash(Symbol, Array(String))
    def add(name, *, message = "is invalid")
      self[name] = [] of String if self[name].empty?
      self[name] << message
    end

    def []=(name : Symbol, message : String)
      add name, message: message
    end

    def [](name : Symbol, message : String)
      self[name]? || [] of String
    end

    def set(name : Symbol, messages : Array(String))
      self[name] = messages
    end

    def added?(name : Symbol, message : String)
      self[name].includes? message
    end

    def full_messages
      keys.flat_map do |key|
        full_message_for key
      end
    end

    def full_message_for(attribute : Symbol)
      self[attribute].map do |message|
        full_message attribute, message
      end
    end

    private def full_message(attribute : Symbol, message : String)
      "#{attribute} #{message}"
    end

  end
end
